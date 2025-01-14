# We install python 3.7 from the AWS repository
FROM public.ecr.aws/lambda/python:3.12

# Set environment variable ENV_NAME = Docker, you'll understand why we do it in a moment.
ENV ENV_NAME Docker

# Copy app.py and requirements.txt in the Docker Image we are building. 
COPY app.py requirements.txt ./

# Upgrade pip if needed
RUN python -m pip install --upgrade pip

# Install Sentence Transformer and other dependencies in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt --default-timeout=2000

# Create the directory 'model'
RUN mkdir -p ./model

# Download the sentence-transfomer model and put it in the directory './model'
RUN curl https://public.ukp.informatik.tu-darmstadt.de/reimers/sentence-transformers/v0.2/all-MiniLM-L6-v2.zip -o ./model/all-MiniLM-L6-v2.zip

# Unzip the model
RUN unzip ./model/all-MiniLM-L6-v2.zip -d ./model/all-MiniLM-L6-v2

# Delete the zip file as we don't need it anymore
RUN rm ./model/all-MiniLM-L6-v2.zip

# Give full access to the dir so that it won't trigger the error permission denied in AWS Lambda
# "[Errno 13] Permission denied: './all-MiniLM-L6-v2/modules.json'",
RUN chmod -R 644 ./model
RUN chmod -R 755 ./model

#The CMD command​ specifies the instruction that is to be executed when a Docker container starts.
CMD ["app.lambda_handler"]
