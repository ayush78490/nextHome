-- ============================================================
-- 01_schema.sql – Next Home Oracle XE Schema Bootstrap
-- Runs automatically on first container start via
-- /container-entrypoint-initdb.d/
-- ============================================================

-- Switch to the app user schema (APP_USER env var = nexthome)
ALTER SESSION SET CURRENT_SCHEMA = nexthome;

-- ── USERS ─────────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    firebase_uid    VARCHAR2(128)   UNIQUE,
    email           VARCHAR2(255)   NOT NULL UNIQUE,
    phone           VARCHAR2(20),
    full_name       VARCHAR2(255)   NOT NULL,
    avatar_url      VARCHAR2(1000),
    role            VARCHAR2(20)    DEFAULT 'tenant' CHECK (role IN ('tenant','landlord','admin')),
    fcm_token       VARCHAR2(500),
    is_verified     NUMBER(1)       DEFAULT 0,
    is_active       NUMBER(1)       DEFAULT 1,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (id)
);

CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_email        ON users(email);

-- ── PROPERTIES ────────────────────────────────────────────────────────────────
CREATE TABLE properties (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    landlord_id     VARCHAR2(36)    NOT NULL,
    title           VARCHAR2(255)   NOT NULL,
    description     CLOB,
    property_type   VARCHAR2(50)    CHECK (property_type IN ('apartment','house','villa','studio','commercial')),
    status          VARCHAR2(20)    DEFAULT 'active' CHECK (status IN ('active','inactive','rented','maintenance')),
    address_line1   VARCHAR2(255)   NOT NULL,
    address_line2   VARCHAR2(255),
    city            VARCHAR2(100)   NOT NULL,
    state           VARCHAR2(100)   NOT NULL,
    country         VARCHAR2(100)   DEFAULT 'India',
    pincode         VARCHAR2(10),
    latitude        NUMBER(10, 7),
    longitude       NUMBER(10, 7),
    rent_per_month  NUMBER(12, 2)   NOT NULL,
    security_deposit NUMBER(12, 2),
    bedrooms        NUMBER(3),
    bathrooms       NUMBER(3),
    area_sqft       NUMBER(10, 2),
    furnished_status VARCHAR2(20)   CHECK (furnished_status IN ('furnished','semi-furnished','unfurnished')),
    amenities       CLOB,           -- JSON array: ["wifi","parking","gym"]
    images          CLOB,           -- JSON array of image URLs
    is_featured     NUMBER(1)       DEFAULT 0,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_properties PRIMARY KEY (id),
    CONSTRAINT fk_properties_landlord FOREIGN KEY (landlord_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_properties_landlord ON properties(landlord_id);
CREATE INDEX idx_properties_city     ON properties(city);
CREATE INDEX idx_properties_status   ON properties(status);
CREATE INDEX idx_properties_location ON properties(latitude, longitude);

-- ── BOOKINGS ──────────────────────────────────────────────────────────────────
CREATE TABLE bookings (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    property_id     VARCHAR2(36)    NOT NULL,
    tenant_id       VARCHAR2(36)    NOT NULL,
    landlord_id     VARCHAR2(36)    NOT NULL,
    start_date      DATE            NOT NULL,
    end_date        DATE,
    status          VARCHAR2(30)    DEFAULT 'pending'
                                    CHECK (status IN ('pending','confirmed','active','completed','cancelled','rejected')),
    rent_amount     NUMBER(12, 2)   NOT NULL,
    deposit_amount  NUMBER(12, 2),
    notes           VARCHAR2(2000),
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_bookings PRIMARY KEY (id),
    CONSTRAINT fk_bookings_property FOREIGN KEY (property_id) REFERENCES properties(id),
    CONSTRAINT fk_bookings_tenant   FOREIGN KEY (tenant_id)   REFERENCES users(id),
    CONSTRAINT fk_bookings_landlord FOREIGN KEY (landlord_id) REFERENCES users(id)
);

CREATE INDEX idx_bookings_property ON bookings(property_id);
CREATE INDEX idx_bookings_tenant   ON bookings(tenant_id);
CREATE INDEX idx_bookings_status   ON bookings(status);

-- ── PAYMENTS ──────────────────────────────────────────────────────────────────
CREATE TABLE payments (
    id                  VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    booking_id          VARCHAR2(36)    NOT NULL,
    payer_id            VARCHAR2(36)    NOT NULL,
    amount              NUMBER(12, 2)   NOT NULL,
    currency            VARCHAR2(3)     DEFAULT 'INR',
    payment_type        VARCHAR2(20)    CHECK (payment_type IN ('rent','deposit','refund','penalty')),
    gateway             VARCHAR2(20)    CHECK (gateway IN ('razorpay','stripe')),
    gateway_order_id    VARCHAR2(255),
    gateway_payment_id  VARCHAR2(255),
    gateway_signature   VARCHAR2(500),
    status              VARCHAR2(20)    DEFAULT 'pending'
                                        CHECK (status IN ('pending','processing','completed','failed','refunded')),
    paid_at             TIMESTAMP,
    metadata            CLOB,           -- JSON: gateway-specific response
    created_at          TIMESTAMP       DEFAULT SYSTIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_payments PRIMARY KEY (id),
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(id),
    CONSTRAINT fk_payments_payer   FOREIGN KEY (payer_id)   REFERENCES users(id)
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_status  ON payments(status);

-- ── CHAT ROOMS ────────────────────────────────────────────────────────────────
CREATE TABLE chat_rooms (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    booking_id      VARCHAR2(36),
    property_id     VARCHAR2(36),
    name            VARCHAR2(255),
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_chat_rooms PRIMARY KEY (id),
    CONSTRAINT fk_chatroom_booking  FOREIGN KEY (booking_id)  REFERENCES bookings(id),
    CONSTRAINT fk_chatroom_property FOREIGN KEY (property_id) REFERENCES properties(id)
);

-- ── CHAT PARTICIPANTS ─────────────────────────────────────────────────────────
CREATE TABLE chat_participants (
    room_id     VARCHAR2(36)    NOT NULL,
    user_id     VARCHAR2(36)    NOT NULL,
    joined_at   TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_chat_participants PRIMARY KEY (room_id, user_id),
    CONSTRAINT fk_cp_room FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    CONSTRAINT fk_cp_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── MESSAGES ──────────────────────────────────────────────────────────────────
CREATE TABLE messages (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    room_id         VARCHAR2(36)    NOT NULL,
    sender_id       VARCHAR2(36)    NOT NULL,
    message_type    VARCHAR2(20)    DEFAULT 'text' CHECK (message_type IN ('text','image','document','system')),
    content         CLOB            NOT NULL,
    media_url       VARCHAR2(1000),
    is_read         NUMBER(1)       DEFAULT 0,
    read_at         TIMESTAMP,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_messages PRIMARY KEY (id),
    CONSTRAINT fk_messages_room   FOREIGN KEY (room_id)   REFERENCES chat_rooms(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id)
);

CREATE INDEX idx_messages_room      ON messages(room_id);
CREATE INDEX idx_messages_created   ON messages(created_at DESC);

-- ── NOTIFICATIONS ─────────────────────────────────────────────────────────────
CREATE TABLE notifications (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    user_id         VARCHAR2(36)    NOT NULL,
    title           VARCHAR2(255)   NOT NULL,
    body            VARCHAR2(1000),
    type            VARCHAR2(50),   -- 'booking_confirmed', 'payment_received', etc.
    data            CLOB,           -- JSON payload
    is_read         NUMBER(1)       DEFAULT 0,
    sent_via_fcm    NUMBER(1)       DEFAULT 0,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_notifications PRIMARY KEY (id),
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_notifications_user    ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- ── PROPERTY REVIEWS ──────────────────────────────────────────────────────────
CREATE TABLE reviews (
    id              VARCHAR2(36)    DEFAULT SYS_GUID() NOT NULL,
    property_id     VARCHAR2(36)    NOT NULL,
    reviewer_id     VARCHAR2(36)    NOT NULL,
    booking_id      VARCHAR2(36),
    rating          NUMBER(2, 1)    NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment         VARCHAR2(2000),
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_reviews PRIMARY KEY (id),
    CONSTRAINT fk_review_property FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id),
    CONSTRAINT uq_review_booking  UNIQUE (booking_id)
);

CREATE INDEX idx_reviews_property ON reviews(property_id);

-- ── SAVED / WISHLIST ──────────────────────────────────────────────────────────
CREATE TABLE saved_properties (
    user_id         VARCHAR2(36)    NOT NULL,
    property_id     VARCHAR2(36)    NOT NULL,
    saved_at        TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_saved_properties PRIMARY KEY (user_id, property_id),
    CONSTRAINT fk_saved_user     FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_property FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

COMMIT;
