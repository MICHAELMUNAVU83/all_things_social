defmodule AllThingsSocial.Influencers.InfluencerNotifier do
  import Swoosh.Email

  alias AllThingsSocial.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"AllThingsSocial", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(influencer, url) do
    deliver(influencer.email, "Confirmation instructions", """

    ==============================

    Hi #{influencer.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a influencer password.
  """
  def deliver_reset_password_instructions(influencer, url) do
    deliver(influencer.email, "Reset password instructions", """

    ==============================

    Hi #{influencer.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a influencer email.
  """
  def deliver_update_email_instructions(influencer, url) do
    deliver(influencer.email, "Update email instructions", """

    ==============================

    Hi #{influencer.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
