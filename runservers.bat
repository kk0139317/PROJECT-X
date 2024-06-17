@echo off

REM Navigate to the frontend directory and start the frontend server
color 02
cd frontend
start cmd /k "npm run dev"

REM Navigate to the backend directory and start the backend server
cd ..\Backend\Backend
color 02
python manage.py runserver_plus --cert-file cert.pem --key-file key.pem 0.0.0.0:8000
 
REM Serve media files
cd ..\..\
start cmd /k "python -m https.server 8001 --directory media"