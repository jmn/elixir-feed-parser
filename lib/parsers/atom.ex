defmodule ElixirFeedParser.Parsers.Atom do
  import ElixirFeedParser.Parsers.Helper

  alias ElixirFeedParser.XmlNode

  def can_parse?(xml) do
    xml
    |> XmlNode.find("/feed")
    |> XmlNode.namespace() == "http://www.w3.org/2005/Atom"
  end

  def parse(xml) do
    feed = XmlNode.find(xml, "/feed")

    url      = feed |> element("link[@type='text/html']", [attr: "href"])
    links    = feed |> elements("link", [attr: "href"])
    feed_url = feed |> element("link[@rel='self']", [attr: "href"])
    hubs     = feed |> elements("link[@rel='hub']", [attr: "href"])

    %{
      authors:         feed |> elements("author/name"),
      title:           feed |> element("title"),
      id:              feed |> element("id"),

      # TODO: handle type attr text/html/xhtml correctly
      description:     feed |> element("subtitle"),
      "atom:subtitle": feed |> element("subtitle"),

      links:           links,
      url:             parse_url(url, links, feed_url),
      hubs:            hubs,
      feed_url:        feed_url,

      # TODO: add optional scheme and label attributes
      categories:      feed |> elements("category", [attr: "term"]),
      contributors:    feed |> elements("contributor/name"),
      updated:         feed |> element("updated"),
      generator:       feed |> element("generator", [attr: "uri"]),
      icon:            feed |> element("icon"),
      logo:            feed |> element("logo"),
      rights:          feed |> element("rights"),

      entries:         parse_entries(feed)
    }
  end

  defp parse_entries(xml) do
    XmlNode.map_children(xml, "entry", fn(e) -> parse_entry(e) end)
  end

  defp parse_entry(entry) do
    url      = entry |> element("link[@type='text/html']")
    links    = entry |> elements("link", [attr: "href"])

    %{
      authors:      entry |> elements("author/name"),
      id:           entry |> element("id"),
      title:        entry |> element("title"),
      updated:      entry |> element("updated"),
      published:    entry |> element("published"),

      # TODO: add optional scheme and label attributes
      categories:   entry |> elements("category", [attr: "term"]),
      contributors: entry |> elements("contributor/name"),

      generator:    entry |> element("generator", [attr: "uri"]),
      rights:       entry |> element("rights"),
      source:       entry |> element("source"),

      links:        links,
      url:          parse_url(url, links),

      summary:      entry |> element("summary"),
      content:      entry |> element("content")
    }
  end

end
