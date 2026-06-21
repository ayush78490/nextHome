const { supabase } = require('./src/config/supabase');

async function test() {
  const { data, error } = await supabase
    .from('properties')
    .select('images')
    .limit(1);
  console.log(error);
  console.log(data);
}
test();
