gc_counter = 0
gc_interval = (ENV["GC_INTERVAL"] || 10).to_i

RSpec.configure do |config|

  config.before(:suite) do
    GC.disable
  end

  config.after(:each) do
    gc_counter += 1
    if gc_counter >= gc_interval
      GC.enable
      GC.start
      GC.disable
      gc_counter = 0
    end
  end

  config.after(:suite) do
    GC.enable
  end
end
