import os
import json
import smtplib
import logging
import argparse
from email.mime.text import MIMEText

# SMTP username and password can be provided as environment variables (but can be
# overriden by a credentials file if one is specified)
EMAIL_USERNAME = os.environ.get("EMAIL_USERNAME", "")
EMAIL_PASSWORD = os.environ.get("EMAIL_PASSWORD", "")


def send_email(
    server_address: str,
    server_port: int,
    subject: str,
    body: str,
    sender: str,
    recipients: list[str],
    username: str,
    password: str,
):
    if not (subject and body and sender and recipients and password):
        raise ValueError("All parameters must be provided and non-empty")
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = ', '.join(recipients)
    with smtplib.SMTP(server_address, server_port) as server:
        server.starttls()
        server.login(username, password)
        server.sendmail(username, recipients, msg.as_string())
    logging.info("Message sent.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Send an email")
    parser.add_argument("--credentials-file", type=str, help="The file containing the email credentials")
    parser.add_argument("--smtp-server", type=str, help="The address of the SMTP server")
    parser.add_argument("--smtp-port", type=int, help="The port of the SMTP server")
    parser.add_argument("--subject", type=str, help="The subject of the email")
    parser.add_argument("--body", type=str, help="The body of the email")
    parser.add_argument("--recipients", type=str, help="A comma separated list of recipients")
    args = parser.parse_args()
    recipients = args.recipients.split(",")
    if (args.credentials_file):
        with open(args.credentials_file) as f:
            credentials = json.load(f)
            EMAIL_USERNAME = credentials.get('username', "")
            EMAIL_PASSWORD = credentials.get('password', "")
    sender = EMAIL_USERNAME
    send_email(
        args.smtp_server,
        args.smtp_port,
        args.subject,
        args.body,
        sender,
        recipients,
        EMAIL_USERNAME,
        EMAIL_PASSWORD
    )
