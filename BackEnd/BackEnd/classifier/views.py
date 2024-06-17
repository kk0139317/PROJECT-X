import os
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
# from .image_classifier import classify_image
from .cat_and_dog import predict_image
from django.conf import settings
from .models import *
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Prediction
from .serializers import *
import json
from PIL import Image
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.decorators import api_view
from django.http import FileResponse
from PIL import Image
from io import BytesIO
import base64
from django.utils.crypto import get_random_string
import uuid


class ImageUploadView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        file_obj = request.data['file']
        media_dir = settings.MEDIA_ROOT
        if not os.path.exists(media_dir):
            os.makedirs(media_dir)
        
        img_path = os.path.join(media_dir, file_obj.name)
        with open(img_path, 'wb+') as f:
            for chunk in file_obj.chunks():
                f.write(chunk)
        
        # Classify the image
        result = predict_image(img_path)
        image = file_obj
        prediction = result['prediction']
        confidence = result['confidence']
        url = request.data['url']
        
        # Get image dimensions
        img = Image.open(img_path)
        original_width, original_height = img.size
        
        # Define model dimensions
        model_width, model_height = 224, 224  # Change as needed to match your model

        # Save to the database
        datasets = Prediction(
            image=image,
            prediction=prediction,
            confidence=confidence,
            url=url,
            image_name=file_obj.name,
            original_width=original_width,
            original_height=original_height,
            model_width=model_width,
            model_height=model_height
        )
        datasets.save()
        
        # Include additional data in the response
        result.update({
            'image_name': file_obj.name,
            'original_width': original_width,
            'original_height': original_height,
            'model_width': model_width,
            'model_height': model_height
        })
        
        return Response(result)

class PredictionList(APIView):
    def get(self, request):
        predictions = Prediction.objects.all().order_by('-timestamp')
        serializer = PredictionSerializer(predictions, many=True)
        return Response(serializer.data)



@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')
    user = authenticate(request, username=username, password=password)
    if user is not None:
        # Authentication successful
        return Response({'message': 'Login successful'}, status=status.HTTP_200_OK)
    else:
        # Authentication failed
        return Response({'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    
def download_file(requst):
    return(FileResponse(open('model.h5', 'rb'), as_attachment=True, filename='model.h5'))



@csrf_exempt
@api_view(['POST'])
def LivePredictor(request):
    try:
        image_data = request.data.get('image')
        if not image_data:
            return Response({'error': 'No image data provided'}, status=400)

        format, imgstr = image_data.split(';base64,')
        img_data = base64.b64decode(imgstr)
        image = Image.open(BytesIO(img_data))

        # Generate a unique filename
        unique_filename = f"{uuid.uuid4().hex[:10]}.jpg"  # Adjust the length or format as needed
        img_path = os.path.join(settings.MEDIA_ROOT, unique_filename)
        image.save(img_path)
        
        # Classify the image
        result = predict_image(img_path)  # Ensure this function works as expected

        original_width, original_height = image.size
        model_width, model_height = 224, 224  # Change as needed to match your model

        # Save to the database (if required)
        datasets = Prediction(
            image=unique_filename,
            prediction=result['prediction'],
            confidence=result['confidence'],
            url=request.data.get('url', ''),
            image_name=unique_filename,
            original_width=original_width,
            original_height=original_height,
            model_width=model_width,
            model_height=model_height
        )
        datasets.save()

        result.update({
            'image_name': unique_filename,
            'original_width': original_width,
            'original_height': original_height,
            'model_width': model_width,
            'model_height': model_height
        })

        return Response(result)

    except Exception as e:
        # Log the error
        print(f"Error during live prediction: {e}")
        return Response({'error': str(e)}, status=500)