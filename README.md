# Reverie - iOS Club Fall 2025 Project

Log and finish your dreams, discover patterns and hidden links, and bring your dreams to life through a creative art experience!

## Officers
* **Technical Leaders:** Amber Verma, Brayden Huguenard
* **Senior Developers:** Shreeya Garg, Ross Klaiber, Nithya Ravula
* **Senior Designer:** Molly Butler

## CoreML

This project uses Core ML models to generate images from text prompts. The model files are not included in this repository due to their large size.

* **Hugging Face Repository:** https://huggingface.co/apple/coreml-stable-diffusion-2-1-base-palettized/tree/main

### How to Download and Set Up the Model

To get the app working, you need to download the `split_einsum` variant of the model.

1.  Navigate to the model's page on Hugging Face using the link above.
2.  **Download:** Click the download icon next to the `coreml-stable-diffusion-2-1-base-palettized_split_einsum.zip` file (the last file on the repo).
3.  Unzip the downloaded file.
4.  Rename the resulting folder to `StableDiffusionResources`.
5.  In Xcode, click the **Reverie** project file (the icon with a hammer).
6.  Next, find **"Targets"** and click **"Build Phases"** in the navigation bar at the top.
7.  Expand the **"Copy Bundle Resources"** section.
8.  Now drag the `StableDiffusionResources` folder into this list. Do **NOT** copy, but do **create folder references**.

**To test, run it on your phone or the simulator. It will not run on the canvas.**
