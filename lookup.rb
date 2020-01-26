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
    all_records=[] 
    for i in 0...dns_raw.size() do
        all_records.push(dns_raw[i].strip().split(", "))
    end

    address_records={} 
    canonicalname_records={} 
    all_records.each  do |i|
        if i[0]=="A"
            address_records[i[1]]=(i.last())
        elsif i[0]=="CNAME"
            canonicalname_records[i[1]]=(i.last())
        end
    end
    return dns_records={"address_records"=>address_records, "canonicalname_records"=>canonicalname_records}
  end

  def resolve(dns_records, lookup_chain,domain)
    if (dns_records["address_records"][domain]!=nil)
        return dns_records["address_records"][domain]
    elsif (dns_records["canonicalname_records"][domain]!=nil)
        resolve(dns_records,lookup_chain,dns_records["canonicalname_records"][domain])
    else
        puts "Error: record not found for #{lookup_chain}"
        exit
    end
  end
  
  dns_records={}
  dns_records = parse_dns(dns_raw)
  lookup_chain = [domain]
  lookup_chain.push(resolve(dns_records, lookup_chain, domain))
  puts lookup_chain.join(" => ")
