from flask import Flask, request, render_template, g
from main import generate_birthday_message, add_event, delete_event
import os
import pickle
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
import datetime

app = Flask(__name__)


def auth():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first time.
    if os.path.exists("sessions/token.pickle"):
        with open("sessions/token.pickle", "rb") as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "credentials.json", scopes=["https://www.googleapis.com/auth/calendar"]
            )
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open("sessions/token.pickle", "wb") as token:
            pickle.dump(creds, token)

    service = build("calendar", "v3", credentials=creds)
    g.service = service


@app.route("/", methods=["GET", "POST"])
def home():
    message = ""
    if request.method == "POST":
        person = {
            "name": request.form.get("name"),
            "age": request.form.get("age"),
            "relationship": request.form.get("relationship"),
            "who_send_the_message": request.form.get("who_send_the_message"),
        }
        message = generate_birthday_message(person, "birthday")
    return render_template("home.html", message=message)


@app.before_request
def before_request():
    auth()


@app.route("/add_event", methods=["GET", "POST"])
def add_event_route():
    service = g.get("service", None)
    if service and request.method == "POST":
        event_type = request.form.get("event_type")
        event_name = request.form.get("event_name")
        event_date = request.form.get("event_date")
        phone_number = request.form.get("phone_number")
        add_event(service, event_type, event_name, event_date, phone_number)
        return "Event added successfully"
    else:
        # Render the form when the route is accessed with a GET request
        return render_template("add_event.html")


@app.route("/delete_event", methods=["GET", "POST"])
def delete_event_route():
    service = g.get("service", None)
    if service:
        if request.method == "POST":
            # Get the event ID from the form data
            event_id = request.form.get("event_id")
            if event_id:
                # Use the delete_event function from main.py
                delete_event(service, event_id)
                return "Event deleted successfully"
            else:
                return "No event ID provided", 400
        else:
            # Get the current date
            now = datetime.datetime.now().isoformat() + "Z"  # 'Z' indicates UTC time

            # Set the end date to the end of the current year
            end_date = (
                datetime.datetime(
                    datetime.datetime.now().year, 12, 31, 23, 59, 59
                ).isoformat()
                + "Z"
            )

            # Fetch the events from the calendar
            events_result = (
                service.events()
                .list(
                    calendarId="primary",
                    timeMin=now,  # Only get events from now until the end of the year
                    timeMax=end_date,
                    singleEvents=True,
                    orderBy="startTime",
                )
                .execute()
            )
            events = [
                event
                for event in events_result.get("items", [])
                if "Birthday".lower() in event.get("summary", "").lower()
                or "Anniversaire".lower() in event.get("summary", "").lower()
            ]

            # Pass the events to the template
            return render_template("delete_event.html", events=events)
    else:
        return "No service available", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=50000, debug=True)
