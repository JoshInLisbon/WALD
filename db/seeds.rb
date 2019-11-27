# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "destroying projects"
Project.destroy_all

puts "destroying users"
User.destroy_all

file = File.open("#{Rails.root}/db/example_xml_files/music.xml")
xml_schema = file.read
# different files to use
# simple_chain.xml (simple way to check order calculations)
# music.xml (the complex music file we have)

puts "creating user, 1@gmail.com, pwdpwd"
user = User.create(
  email: '1@gmail.com',
  password: 'pwdpwd'
)
puts "creating project"
project = Project.create(
  name: 'Example',
  user: user,
  xml_schema: xml_schema
)

puts "show url:"

puts "http://localhost:3000/projects/#{project.id}"
