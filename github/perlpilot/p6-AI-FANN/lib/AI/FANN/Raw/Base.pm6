unit module AI::FANN::Raw::Base;

use NativeCall;

sub fannlib is export { 'libfann.so' } 

constant float                  is export = num32;
constant fann_type              is export = num32;
constant fann_activationfunc    is export = int32;
constant fann_nettype           is export = int32;
constant fann_errno             is export = int32;
constant fann_train             is export = int32;

enum fann_nettype_enum is export « :FANN_NETTYPE_LAYER(0) FANN_NETTYPE_SHORTCUT »;

enum fann_activationfunc_enum is export «
    :FANN_LINEAR(0) FANN_THRESHOLD FANN_THRESHOLD_SYMMETRIC
    FANN_SIGMOID FANN_SIGMOID_STEPWISE FANN_SIGMOID_SYMMETRIC FANN_SIGMOID_SYMMETRIC_STEPWISE
    FANN_GAUSSIAN FANN_GAUSSIAN_SYMMETRIC FANN_GAUSSIAN_STEPWISE
    FANN_ELLIOT FANN_ELLIOT_SYMMETRIC
    FANN_LINEAR_PIECE FANN_LINEAR_PIECE_SYMMETRIC
    FANN_SIN_SYMMETRIC FANN_COS_SYMMETRIC
    FANN_SIN FANN_COS
»;

enum fann_train_enum is export «
    :FANN_TRAIN_INCREMENTAL(0)
    FANN_TRAIN_BATCH
    FANN_TRAIN_RPROP
    FANN_TRAIN_QUICKPROP
    FANN_TRAIN_SARPROP
»;

enum fann_errno_enum is export «
    :FANN_E_NO_ERROR(0)
    FANN_E_CANT_OPEN_CONFIG_R
    FANN_E_CANT_OPEN_CONFIG_W
    FANN_E_WRONG_CONFIG_VERSION
    FANN_E_CANT_READ_CONFIG
    FANN_E_CANT_READ_NEURON
    FANN_E_CANT_READ_CONNECTIONS
    FANN_E_WRONG_NUM_CONNECTIONS
    FANN_E_CANT_OPEN_TD_W
    FANN_E_CANT_OPEN_TD_R
    FANN_E_CANT_READ_TD
    FANN_E_CANT_ALLOCATE_MEM
    FANN_E_CANT_TRAIN_ACTIVATION
    FANN_E_CANT_USE_ACTIVATION
    FANN_E_TRAIN_DATA_MISMATCH
    FANN_E_CANT_USE_TRAIN_ALG
    FANN_E_TRAIN_DATA_SUBSET
    FANN_E_INDEX_OUT_OF_BOUND
    FANN_E_SCALE_NOT_PRESENT
    FANN_E_INPUT_NO_MATCH
    FANN_E_OUTPUT_NO_MATCH
»;

class fann_connection is repr('CStruct') is export {
    has uint32 $from-neuron;
    has uint32 $to-neuron;
    has fann_type $weight;
}

class fann              is repr('CPointer') is export {*}
class fann_train_data   is repr('CPointer') is export {*}
class fann_error        is repr('CPointer') is export {*}

