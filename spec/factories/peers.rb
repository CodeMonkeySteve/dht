Factory.sequence :peer_url do |n|
  "http://localhost:3000/#{n}/"
end

Factory.define :peer do |p|
  p.url {  Factory.next :peer_url  }
end

