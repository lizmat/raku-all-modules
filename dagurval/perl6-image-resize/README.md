NAME
====

Image::Resize - Resize images using GD

SYNOPSIS
========

    use Image::Resize;

    # Create a mini-me 1/10th your size
    resize-image("me.png", "mini-mi.jpg", 0.1);

    # Resize to exactly 400x400 pixels.
    resize-image("original.jpg", "resized.gif", 400, 400);

DESCRIPTION
===========

`Image::Resize` takes an image and resizes it. Can read jpg, png and gif images and store the image in any format.

no-resample
-----------

Disable resample, which uses "smooth" copying from a large image to a smaller one, using a weighted average of the pixels.

jpeg-quality
------------

When copying to a jpeg image, you may specify this to change the quality of the resized image. Range 0-95. A negative value will set it to default jpeg value of GD.
