# Neuronalyzer - User Manual

**The software is compatible with MATLAB R2020b or newer.** <br/>
To get started, download the latest Neuronalyzer version from the GitHub repository.
Then open the file index.m in MATLAB and run it.

Required toolboxes: Computer Vision, Navigation, Robotics System, Image Processing, 
Curve Fitting, Signal Processing, Statistics and Machine Learning, Phased Array System.

<br/>

**1. Load an image or an existing project** <br/>
    Use the “Load Data” button to load an image(s), or the “Load Project” button to load an existing
    project file(s). Then, use the “Project” menu to navigate between the different images/projects. You
    can load multiple image/project files at once, or load a project file that contains multiple projects.  <br/><br/>
    Use the tables at the bottom-right corner to add meta-data. The first table allows you to enter
    experimental information such as scale-bar, temperature and strain name (the third column is used
    for units). The second table allows you to enter analysis information for reproducibility. This includes
    the version and commit id of the code used for the analysis, as well as the date and the name of the
    person that performed the analysis. You can find the commit id on the GitHub repository (for
    example: 357b6ac). **The scale-bar is set to 1 as default. Make sure to set it to the correct value**
    **for each loaded image/project**.

![Screenshot_Start](https://user-images.githubusercontent.com/35100851/111909172-1b9b9880-8a54-11eb-82cf-d8203d966276.png)

<br/>

**2. Denoising** <br/>
    Next, you can use the “Denoise Image” button to apply a denoising neural network that will classify pixels into neuron and non-neuron.
	To display the denoised image, in the “Reconstructions” menu, choose CNN **→** CNN Image - RGB.

![Screenshot_CNN](https://user-images.githubusercontent.com/35100851/109167973-43118500-7776-11eb-9449-3ac13276bf51.png)

<br/>

**3. Manual annotation** <br/>
    Once the image is denoised, you can display it as a binary image, and make corrections if necessary “Reconstructions” menu 
	(Binary Image ​ **→** ​ Binary Image - RGB). <br/><br/>
    To filter out small objects, set the threshold value in the top-right spinner (here set to 50), then click "Apply Changed". <br/><br/>
	In this image a colormap is used for visual and annotation purposes (see below), where “White” (1)
    and “Black” (0) are displayed using their intensities in the original grayscale image. <br/><br/>
    You can use the drawing or annotation modes to manually edit the binary image. First, zoom in to
    magnify a certain image region and choose a marker size. Then, choose “Drawing Mode” or
    “Annotation Mode” to start editing the image. In drawing mode, a left-click initiates drawing, and a
    right-click initiates erasing. Click once on the image, release, and then left-click and hold to start
    drawing. Annotation mode works in a similar way but with individual clicks that add or remove pixels
    around the clicked position. Switch back to “Default Mode” once finished, or in order to use the
    zoom function. The result is automatically saved. <br/><br/>
    You can save your work at any time using the “Save Project” button.
    
![Screenshot_Annotation](https://user-images.githubusercontent.com/35100851/109167991-499ffc80-7776-11eb-94cf-1429548dc6a1.png)

<br/>

Following manual correction, you can display a combined image showing both the CNN-derived image and the corrections labeled in different colors.

![Screenshot_CNN+Annotation](https://user-images.githubusercontent.com/35100851/109168016-515fa100-7776-11eb-8edd-732d259def9e.png)

<br/>

Use the skeleton view (Reconstructions → Skeleton) to check for gaps in the binary image. In this view, each connected component appears in a different color.
It is absolutely fine to have separated components, but if you see components that should be connected but are not, then you should go back to the binary image and fix this.

![Screenshot_Skeleton](https://user-images.githubusercontent.com/35100851/111909190-3706a380-8a54-11eb-94c3-688d3ba41c32.png)

<br/>

**4. Neuron tracing** <br/>
    To obtain the trace of the neurons, click the “Trace Neuron” button. Once finished, the resulting
    trace is displayed. You can use the “Project” menu to navigate between the different traced images.
   
![Screenshot_Trace](https://user-images.githubusercontent.com/35100851/111909214-4ab20a00-8a54-11eb-92d0-f503b6fe06ed.png)

<br/>

**5. Feature extraction and neuron axes** <br/>
    Once the tracing is done, click the "Extract Features" button to extract various morphological features from the trace.
	In particular, the neuron axes are mapped (Reconstructions ​ **→** ​ Axes). To tweak the axes positions manually, change to annotation mode and click the “Apply Changes" button.
	You can use the spinner to specify the number of interactive points (here set to 25 points), then click the “Apply Changes” button.
	Once finished, click again the "Extract Features" button, as other computations depend on these axes.

![Screenshot_Axes](https://user-images.githubusercontent.com/35100851/111909224-58678f80-8a54-11eb-8ccf-744feda48483.png)

<br/>

**6. Validation** <br/>
    Once the images have been traced, you can use the “Reconstructions” menu to visualize various
    morphological features. The examples below show the azimuthal position (top), and
    the classification of neuronal elements into four morphological classes (bottom).

![Screenshot_Azimuthal_Position](https://user-images.githubusercontent.com/35100851/111909236-6c12f600-8a54-11eb-959e-d8ea25cb8f0f.png)

![Screenshot_Classes](https://user-images.githubusercontent.com/35100851/111909243-703f1380-8a54-11eb-8502-6d4176c82cc9.png)

<br/>

**7. Analysis** <br/>
    Finally, use the “Plots” menu to display quantifications of the extracted features. Use the control
    panel to specify plot parameters, then click “Apply Changes”. Plot parameters include bin-size,
    normalization, statistics and plot types. The examples below show the density of
    neuronal elements along the neuron’s midline, averaged across wild-type animals (top), and the mean and standard deviation
    of neuronal length per morphological class for each group of animals (bottom).

![Screenshot_Plots_Gradient](https://user-images.githubusercontent.com/35100851/111909276-95338680-8a54-11eb-94ae-315f3e22b4e9.png)

![Screenshot_Plots_Length](https://user-images.githubusercontent.com/35100851/114274965-ac90de80-9a18-11eb-841b-5c683514506c.png)
