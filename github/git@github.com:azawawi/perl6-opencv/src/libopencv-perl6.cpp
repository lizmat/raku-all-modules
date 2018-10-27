
#include <stdio.h>

#include <opencv2/opencv.hpp>

#ifdef _WIN32
#define EXTERN_C extern "C" __declspec(dllexport)
#else
#define EXTERN_C extern "C"
#endif

EXTERN_C void * cv_highgui_imread(char *filename, int flags ) {
  cv::Mat mat = cv::imread(filename, flags);
  return (void *)new cv::Mat(mat);
}

EXTERN_C int cv_highgui_imwrite(char *filename, char *mat) {
  cv::Mat& matz   = *((cv::Mat*)mat);
  return cv::imwrite(filename, matz);
}

EXTERN_C int cv_mat_rows(char *mat) {
  cv::Mat *t = (cv::Mat *)mat;
  return t->rows;
}

EXTERN_C int cv_mat_cols(char *mat) {
  cv::Mat *t = (cv::Mat *)mat;
  return t->cols;
}

EXTERN_C uchar* cv_mat_data(char *mat) {
  cv::Mat *t = (cv::Mat *)mat;
  return t->data;
}

EXTERN_C void * cv_mat_clone(char *mat) {
  cv::Mat *t = (cv::Mat *)mat;
  return (void *)(new cv::Mat(t->clone()));
}

EXTERN_C void cv_highgui_imshow(char *winname, void * mat) {
  cv::Mat& matz   = *((cv::Mat*)mat);
  cv::imshow(winname, matz);
}

EXTERN_C void cv_highgui_namedWindow(char *winname, int flags ) {
  cv::namedWindow(winname, flags);
}

EXTERN_C void cv_highgui_moveWindow(char *winname, int x, int y) {
  cv::moveWindow(winname, x, y);
}

EXTERN_C void cv_highgui_resizeWindow(char *winname, int width, int height) {
  cv::moveWindow(winname, width, height);
}

EXTERN_C void cv_highgui_waitKey(int delay) {
  cv::waitKey(delay);
}

EXTERN_C void cv_highgui_destroyWindow(char *winname) {
  cv::destroyWindow(winname);
}

EXTERN_C void cv_highgui_destroyAllWindows() {
  cv::destroyAllWindows();
}

EXTERN_C void cv_highgui_createTrackbar(char *trackbarname, char *winname, int value, int count, cv::TrackbarCallback onChange) {
  static int *pValue = new int;
  *pValue = value;
  cv::createTrackbar(trackbarname, winname, pValue, count, onChange);
}

EXTERN_C void cv_highgui_rectangle(
    void * mat,
    int x1, int y1, int  x2, int y2,
    int b, int g, int r,
    int thickness,
    int lineType,
    int shift
) {
  cv::Mat& matz   = *((cv::Mat*)mat);
  cv::rectangle(
      matz,
      cv::Point(x1, y1),
      cv::Point(x2, y2),
      cv::Scalar(b, g, r),
      thickness,
      lineType,
      shift
  );
}

EXTERN_C void cv_highgui_circle(
    void * mat,
    int cx, int cy, int radius,
    int b, int g, int r,
    int thickness,
    int lineType,
    int shift
) {
  cv::Mat& matz   = *((cv::Mat*)mat);
  cv::circle(
      matz,
      cv::Point(cx, cy),
      radius,
      cv::Scalar(b, g, r),
      thickness,
      lineType,
      shift
  );
}

EXTERN_C void cv_photo_fastNlMeansDenoisingColored(
  char* src,
  char* dst,
  int h,
  int hColor,
  int templateWindowSize,
  int searchWindowSize
)
{
  cv::Mat& srcMat = *((cv::Mat*)src);
  cv::Mat& dstMat = *((cv::Mat*)dst);
  cv::fastNlMeansDenoisingColored(
    srcMat, dstMat, h, hColor, templateWindowSize, searchWindowSize);
}
