def get_command_line_argument
 
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_records = {}
  dns_raw.each do |rec|
    rec=rec.chomp
    unless rec[0] == "#" || rec.empty?
      records = rec.split(/,/)
      records = records.map {|recd| recd.strip()}
      unless dns_records.has_key?(records[0])
        dns_records.store(records[0],[[records[1],records[2]]])
      else
        dns_records[records[0]].push([records[1],records[2]])
      end
    end
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  for dom in dns_records["A"]
    if (domain == dom[0])
      lookup_chain.push(dom[1])
      return lookup_chain
    end
  end
  for dom in dns_records["CNAME"]
    if (domain == dom[0])
      lookup_chain.push(dom[1])
      return resolve(dns_records, lookup_chain, dom[1])
    end
  end
  lookup_chain.push("Further mapping not found in Zone file")
  return lookup_chain
end
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
