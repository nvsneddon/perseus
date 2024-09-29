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

  def deliver_login_link(email, url) do
    deliver(email, "Login link", """
      Hello,

      You can log into your account by visiting the URL below:

      #{url}

      If you didn't request a login link, please ignore this.

      The Aquagoats Team
    """)
  end

  def deliver_signup_link(email, url) do
    deliver(email, "Signup link", """
      Hello,

      We're excited for you to join Aquagoats. Here's the link to register your account.

      #{url}

      If you didn't request a signup link, please ignore this.

      The Aquagoats Team
    """)
  end
end
