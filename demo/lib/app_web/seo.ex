defmodule AppWeb.Seo do
  @moduledoc false

  alias App.Docs

  @site_name "PUI"
  @site_title_suffix "PUI Demo"
  @default_page_title "Phoenix LiveView UI Toolkit"
  @default_description "PUI is a Phoenix LiveView UI toolkit with accessible, theme-ready components and interactive documentation."
  @docs_description "Browse the PUI documentation for installation guidance, component usage, and interactive LiveView examples."
  @default_image_path "/images/pui-hook-2d.png"

  def default_meta do
    build_meta(%{
      title: @default_page_title,
      description: @default_description,
      path: "/",
      type: "website"
    })
  end

  def landing_meta do
    default_meta()
  end

  def docs_index_meta do
    build_meta(%{
      title: "Documentation",
      description: @docs_description,
      path: "/docs",
      type: "website"
    })
  end

  def doc_meta(doc) do
    build_meta(%{
      title: "#{doc.title} Documentation",
      description: doc.description,
      path: "/docs/#{doc.id}",
      type: "article"
    })
  end

  def build_meta(attrs) do
    attrs = Map.new(attrs)
    path = Map.get(attrs, :path, "/")
    canonical_url = Map.get(attrs, :canonical_url, absolute_url(path))
    image_url = Map.get(attrs, :image_url, absolute_url(@default_image_path))
    title = Map.get(attrs, :title, @default_page_title)

    %{
      title: title_tag(title),
      description: Map.get(attrs, :description, @default_description),
      canonical_url: canonical_url,
      image_url: image_url,
      robots: Map.get(attrs, :robots, "index,follow"),
      site_name: @site_name,
      type: Map.get(attrs, :type, "website"),
      twitter_card: Map.get(attrs, :twitter_card, "summary_large_image")
    }
  end

  def title_tag(title), do: "#{title} · #{@site_title_suffix}"

  def absolute_url(path) do
    base = AppWeb.Endpoint.url() |> ensure_trailing_slash()
    base |> URI.merge(path) |> to_string()
  end

  def sitemap_entries do
    static_pages = [
      %{loc: absolute_url("/"), changefreq: "weekly", priority: "1.0"}
    ]

    doc_pages =
      Docs.all_docs()
      |> Enum.map(fn doc ->
        %{loc: absolute_url("/docs/#{doc.id}"), changefreq: "weekly", priority: "0.8"}
      end)

    static_pages ++ doc_pages
  end

  def render_sitemap(entries) do
    urls =
      Enum.map_join(entries, "", fn entry ->
        """
          <url>
            <loc>#{xml_escape(entry.loc)}</loc>
            <changefreq>#{entry.changefreq}</changefreq>
            <priority>#{entry.priority}</priority>
          </url>
        """
      end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{urls}</urlset>
    """
  end

  defp ensure_trailing_slash(url) do
    if String.ends_with?(url, "/"), do: url, else: "#{url}/"
  end

  defp xml_escape(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
