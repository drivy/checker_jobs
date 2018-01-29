module EmailHelpers
  def sends_an_email
    expect { subject }.
      to change { ActionMailer::Base.deliveries.count }.
      from(0).to(1)
  end

  def doesn_t_send_any_email
    expect { subject }.
      not_to change { ActionMailer::Base.deliveries.count }.
      from(0)
  end
end
