defmodule AppWeb.SeoController do
  use AppWeb, :controller

  alias AppWeb.Seo

  def robots(conn, _params) do
    body = """
    User-agent: *
    Allow: /
    Disallow: /__test__/

    Sitemap: #{Seo.absolute_url("/sitemap.xml")}
    """

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, body)
  end

  def sitemap(conn, _params) do
    body =
      Seo.sitemap_entries()
      |> Seo.render_sitemap()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, body)
  end
end
