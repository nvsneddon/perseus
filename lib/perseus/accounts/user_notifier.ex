defmodule Perseus.Accounts.UserNotifier do
  import Swoosh.Email

  alias Perseus.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Aquagoats", "no-reply@aquagoats.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_magic_link(email, url) do
    deliver(email, "Login link", """
      Hello,

      You can log into your account by visiting the URL below:

      #{url}

      If you didn't request a login link, please ignore this.

      The Aquagoats Team
    """)
  end
end
