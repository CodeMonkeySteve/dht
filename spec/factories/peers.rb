Factory.sequence :peer_key do |n|
  Key.new n
end

Factory.define :peer do |p|
  p.key {  Factory.next :peer_key  }
end

