# Reverie - iOS Club Fall 2025 Project
Log and finish your dreams, discover patterns and hidden links, and bring your dreams to life through a creative art experience!

# Officers
Technical Leaders: Amber Verma, Brayden Huguenard

Senior Developers: Shreeya Garg, Ross Klaiber, Nithya Ravula

Senior Designer: Molly Butler


# CoreML

This project uses Core ML models to generate images from text prompts. The model files are not included in this repository due to their large size.

Hugging Face Repository: apple/coreml-stable-diffusion-2-1-base-palettized

How to Download and Set Up the Model

To get the app working, you need to download the split_einsum variant of the model.

Navigate to the model's page on Hugging Face using the link above.

Download: Click the download icon next to the coreml-stable-diffusion-2-1-base-palettized_split_einsum.zip file (the last file on the repo).

Unzip the downloaded file.

Rename the resulting folder to StableDiffusionResources.

On XCode, click the Reverie non-folder icon, it has a Hammer in the icon.

Next find "Targets" and click "Build Phases" on the Navagation Bar at the top.

Drop down "Copy Bundle Resources".

Now drag the StableDiffusionResouces folder into this. Do NOT copy and create folder references.

To test, run it on your phone or the simulator. It will not run on the canvas.
