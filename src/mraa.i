%rename("%(strip:[MRAA_])s", %$isenumitem) "";

%include stdint.i
%include std_string.i
%include exception.i
%include carrays.i
%include typemaps.i

%array_class(uint8_t, uint8Array);

// i2c write()
%typemap(in) (const uint8_t *data, int length) {
  if (PyByteArray_Check($input)) {
    // whilst this may seem 'hopeful' it turns out this is safe
    $1 = (uint8_t*) PyByteArray_AsString($input);
    $2 = PyByteArray_Size($input);
  }
}

%typemap(out) uint8_t*
{
  // need to loop over length
  $result = PyByteArray_FromStringAndSize((char*) $1, arg2);
}


%newobject I2c::read(uint8_t *data, int length);

%typemap(in) (uint8_t *data, int length) {
   if (!PyInt_Check($input)) {
       PyErr_SetString(PyExc_ValueError, "Expecting an integer");
       return NULL;
   }
   $2 = PyInt_AsLong($input);
   if ($2 < 0) {
       PyErr_SetString(PyExc_ValueError, "Positive integer expected");
       return NULL;
   }
   $1 = (uint8_t*) malloc($2 * sizeof(uint8_t));
}

%typemap(argout) (uint8_t *data, int length) {
   Py_XDECREF($result);   /* Blow away any previous result */
   if (result < 0) {      /* Check for I/O error */
       free($1);
       PyErr_SetFromErrno(PyExc_IOError);
       return NULL;
   }
   // Append output value $1 to $result
   $result = PyByteArray_FromStringAndSize((char*) $1, result);
   free($1);
}


#ifdef DOXYGEN
    %include common_hpp_doc.i
    %include gpio_class_doc.i
    %include i2c_class_doc.i
    %include pwm_class_doc.i
    %include aio_class_doc.i
    %include spi_class_doc.i
    %include uart_class_doc.i
#endif

%{
    #include "common.hpp"
    #include "gpio.hpp"
    #include "pwm.hpp"
    #include "i2c.hpp"
    #include "spi.hpp"
    #include "aio.hpp"
    #include "uart.hpp"
%}

%init %{
    //Adding mraa_init() to the module initialisation process
    mraa_init();
%}

%exception {
    try {
        $action
    } catch(const std::invalid_argument& e) {
        SWIG_exception(SWIG_ValueError, e.what());
    } catch(...) {
        SWIG_exception(SWIG_RuntimeError, "Unknown exception");
    }
}

//%apply (char *STRING, size_t LENGTH) { (char *data, size_t length) };

%include "common.hpp"

%include "types.h"

#### GPIO ####

%include "gpio.hpp"

#### i2c ####

%include "i2c.hpp"

#### PWM ####

%include "pwm.hpp"

#### SPI ####

%include "spi.hpp"

#### AIO ####

%include "aio.hpp"

#### UART ####

%include "uart.hpp"
