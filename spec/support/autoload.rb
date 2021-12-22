Dir[File.join(__dir__, '../models/**/*.rb')].each do |f|
  basename = File.basename(f, ".rb")
  autoload basename.camelcase.to_sym, "models/#{basename}"
end
