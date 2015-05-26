uri = URI.parse('http://notebook.erikostrom.com')

xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "A notebook."
  xml.subtitle "By Erik Ostrom, web developer."
  xml.id uri
  xml.link "href" => uri
  xml.link "href" => uri + '/feed.xml', "rel" => "self"
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name "Erik Ostrom" }

  blog.articles[0..5].each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => uri + article.url
      xml.id uri + article.url
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Erik Ostrom" }
      xml.summary article.summary, "type" => "html"
      xml.content article.body, "type" => "html"
    end
  end
end