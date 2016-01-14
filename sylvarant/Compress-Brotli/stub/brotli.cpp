/*
 * =====================================================================================
 *
 *       Filename:  brotli-helper.cpp
 *
 *    Description:  Provide a simple C interface to brotli
 *
 *        Created:  10/30/2015 15:04:57
 *       Compiler:  gcc
 *
 *         Author:  ajhl
 *
 * =====================================================================================
 */

#include <vector>
#include <cstring>
#include <cstdint>
#include <stdio.h>
#include <brotli/dec/decode.h>
#include <brotli/enc/encode.h>

// global variable output, to deal with memory leaks
// due to perl6 native call being very limited
std::vector<uint8_t> buffer;

// callback
int callback(void* data, const uint8_t* more, size_t count) 
{
  buffer.insert(buffer.end(), more, more + count);
  return (int)count;
}


extern "C" {

  // Brotli compression configuration
 typedef struct config_s {
    char mode;
    char quality;
    char lgwin;
    char lgblock;
  } config;


  /* 
   * ===  FUNCTION  ======================================================================
   *         Name:  decompress_buffer
   *  Description:  use the brotli compression function
   * =====================================================================================
   */ 
  uint8_t * decompress_buffer(size_t encoded_size, const uint8_t* encoded_buffer, size_t* decoded_size)
  {
    /* Brotlin Input */
    BrotliMemInput memin;
    BrotliInput in = BrotliInitMemInput(encoded_buffer,encoded_size,&memin);

    /* Brotlin Output */
    BrotliOutput out;
    out.cb_ = &callback;
    buffer.clear();
    out.data_ = &buffer;
    
    if(BrotliDecompress(in, out)){
      *decoded_size = buffer.size(); 
      return buffer.data();
    } else {
      *decoded_size = -1;
      return NULL;
    }
  }

  // to limit memory usage
  void clear_internal_buffer()
  {
    buffer.clear(); 
  }


  /* 
   * ===  FUNCTION  ======================================================================
   *         Name:  compress_buffer
   *  Description:  use the brotli buffer compression function
   * =====================================================================================
   */ 
  size_t compress_buffer(size_t input_size, const uint8_t* input_buffer,size_t* encoded_size, uint8_t* encoded_buffer, config * conf)
  {
    brotli::BrotliParams params;
    params.mode = (enum brotli::BrotliParams::Mode) conf->mode; 
    params.quality = (int) conf->quality;
    params.lgwin = (int) conf->lgwin;
    params.lgblock = (int) conf->lgblock;
    return brotli::BrotliCompressBuffer(params,input_size,input_buffer,encoded_size,encoded_buffer);
  }


}

