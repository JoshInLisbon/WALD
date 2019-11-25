class ProjectsController < ApplicationController
  def show
    file = File.open('example.xml')
    doc = Nokogiri::XML(file)

    doc.root.xpath('table').each do |table|
      name = table.xpath('name').text
    end

raise
  end
end


# >> docu.root.search("table").count
# => 2
# >> docu.root.search("table").first.search("row")

# >> docu.root.search("table").first.search("row").count
# => 3
# >> docu.root.search("table").first

# >> docu.root.search("table").first.attribute("name")
# => #<Nokogiri::XML::Attr:0x3f82be0858d8 name="name" value="users">
# >> docu.root.search("table").first.attribute("name").value
# => "users"
# >> docu.root.search("table").first.attribute("name").value.capitalize[0..-1]
# => "Users"
# >> docu.root.search("table").first.attribute("name").value.capitalize[0..-2]
# => "User"
# >> docu.root.search("table").last.search("row")
# =
# >> docu.root.search("table").last.search("relation")
