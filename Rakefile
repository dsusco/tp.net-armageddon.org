require 'json'
require 'open-uri'
require 'yaml'

task :get_special_rules do
  Rake::Task[:get_json].invoke(:special_rules)
end

task :get_weapons do
  Rake::Task[:get_json].invoke(:weapons)
end

task :get_json, [:type] do |t, args|
  collection_path = Helper::collection_path(args.type)

  FileUtils::mkdir_p collection_path

  JSON.parse(open("http://miniwars.co.uk/netea-json/#{args.type}").read()).each do |obj|
    next if (id = obj['rule_netea_url']) == ''

    file_path = File.join(collection_path, "#{id}.md")

    if File.exists?(file_path)
      if YAML::load(File.open(file_path))['timestamp'] != Time.at(obj['edit_date'].to_s[0..-4].to_i)
        p "Updating: #{file_path}"
        Helper::write_file(file_path, args.type[0...-1], obj)
      end
    else
      p "Creating: #{file_path}"
      Helper::write_file(file_path, args.type[0...-1], obj)
    end
  end
end

class Helper
  @config = YAML::load(File.open('./_config.yml'))

  def self.collection_path(collection)
    File.join(@config['source'], "_#{collection}")
  end

  def self.write_file(file_path, type, obj)
    File.open(file_path, 'w') { |file| file.write(send("#{type}_template", obj)) }
  end

  def self.special_rule_template(sr)
    hash = default_keys(sr)

    hash['abbr'] = sr['rule_abbreviation'] unless sr['rule_abbreviation'].empty?

    "#{hash.to_yaml}---"
  end

  def self.weapon_template(w)
    hash = default_keys(w)

    w['weapon_details'].each_with_index do |mode, i|
      special_rules = weapon_special_rules_array(mode)

      if i == 0
        hash['range'] = mode['weapon_range']
        hash['firepower'] = mode['weapon_firepower']
        hash['special_rules'] = special_rules unless special_rules.empty?
      else
        hash['modes'] << {
          'boolean' => mode['weapon_boolean'],
          'range' => mode['weapon_range'],
          'firepower' => mode['weapon_firepower']
        }
        hash['modes'][i-1]['special_rules'] = special_rules unless special_rules.empty?
      end
    end

    "#{hash.to_yaml}---"
  end

  private

  def self.default_keys(obj)
    hash = Hash.new { |h, k| h[k] = [] }

    hash['id'] = obj['rule_netea_url']
    hash['timestamp'] = Time.at(obj['edit_date'].to_s[0..-4].to_i)
    hash['name'] = obj['title']

    hash
  end

  def self.weapon_special_rules_array(mode)
    mode['weapon_abilities'].scan(/\[([a-z][a-z0-9\-]+)\]/).flatten || nil
  end
end