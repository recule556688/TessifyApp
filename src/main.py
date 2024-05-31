import os
import pickle
from ollama import generate
import datetime
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request


def add_event(service, event_type, event_name, event_date, phone_number):
    # Create the event
    event = {
        "summary": event_name,
        "description": f"Phone Number: {phone_number}",
        "start": {
            "date": event_date,
            "timeZone": "Europe/Paris",
        },
        "end": {
            "date": event_date,
            "timeZone": "Europe/Paris",
        },
    }

    # If the event is a birthday, add it to the 'Birthdays' calendar
    if event_type.lower() == "birthday":
        event["transparency"] = "transparent"  # Make the event appear as free time

    # Add the event to the calendar
    event = service.events().insert(calendarId="primary", body=event).execute()

    print(f"Event created: {event.get('htmlLink')}")


def delete_event(service, event_id):
    # Delete the selected event
    service.events().delete(calendarId="primary", eventId=event_id).execute()
    print(f"Event deleted: {event_id}")


def display_events(service):
    # Get the current date
    now = datetime.datetime.now().isoformat() + "Z"  # 'Z' indicates UTC time

    # Set the end date to the end of the current year
    end_date = (
        datetime.datetime(datetime.datetime.now().year, 12, 31, 23, 59, 59).isoformat()
        + "Z"
    )

    # Get the events
    events_result = (
        service.events()
        .list(
            calendarId="primary",
            timeMin=now,
            timeMax=end_date,
            singleEvents=True,
            orderBy="startTime",
        )
        .execute()
    )
    events = events_result.get("items", [])

    for event in events:
        # Only display the event if the summary contains 'Birthday' or 'Anniversaire'
        if "Birthday" in event["summary"] or "Anniversaire" in event["summary"]:
            start = event["start"].get("dateTime", event["start"].get("date"))
            print(f"Event: {event['summary']}")
            print(f"Start: {start}")
            print(f"Description: {event.get('description', 'No description')}")
            print("------------------------")


mom = {
    "name": "Mom",
    "age": 45,
    "relationship": "mom and son",
    "who_send_the_message": "Luca",
}


def generate_birthday_message(person, event_type):
    model = "mistral"
    if event_type == "birthday":
        prompt = f"Create a warm, heartfelt, and affectionate birthday message for a {person['age']} year old named {person['name']}. The message is being sent by {person['who_send_the_message']}, who is her son. The message should convey love, appreciation, and wishes for a joyful birthday but also staying short and powerful."
        response = generate(model, prompt)
        return response["response"]


def main():
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

    while True:
        # Ask the user what they want to do
        action = input("Do you want to add, delete, or display events? ").lower()

        if action == "add":
            event_type = input("Is the event a birthday? (yes/no) ").lower()
            add_event(service, event_type)
        elif action == "delete":
            delete_event(service)
        elif action == "display":
            display_events(service)
        else:
            print("Invalid action.")

        # Ask the user if they want to perform another action
        another_action = input(
            "Do you want to perform another action? (yes/no) "
        ).lower()

        if another_action != "yes":
            break


if __name__ == "__main__":
    main()
