// (C) 2017 Tino Reichardt

#define BROTLI_STATIC_LINKING_ONLY
#include "../../../C/Alloc.h"
#include "../../../C/Threads.h"
#include "../../../C/brotli/decode.h"
#include "../../../C/zstdmt/brotli-mt.h"

#include "../../Windows/System.h"
#include "../../Common/Common.h"
#include "../../Common/MyCom.h"
#include "../ICoder.h"
#include "../Common/StreamUtils.h"
#include "../Common/RegisterCodec.h"
#include "../Common/ProgressMt.h"

struct BrotliStream {
  ISequentialInStream *inStream;
  ISequentialOutStream *outStream;
  ICompressProgressInfo *progress;
  UInt64 *processedIn;
  UInt64 *processedOut;
};

extern int BrotliRead(void *Stream, BROTLIMT_Buffer * in);
extern int BrotliWrite(void *Stream, BROTLIMT_Buffer * in);

namespace NCompress {
namespace NBROTLI {

struct DProps
{
  DProps() { clear (); }
  void clear ()
  {
    memset(this, 0, sizeof (*this));
    _ver_major = BROTLI_VERSION_MAJOR;
    _ver_minor = BROTLI_VERSION_MINOR;
    _level = 1;
  }

  Byte _ver_major;
  Byte _ver_minor;
  Byte _level;
};

#ifndef NO_READ_FROM_CODER
Z7_CLASS_IMP_COM_4(
  CDecoder,
  ICompressCoder,
  ICompressSetDecoderProperties2,
  ICompressSetInStream,
  ICompressSetCoderMt
)
#else
Z7_CLASS_IMP_COM_3(
  CDecoder,
  ICompressCoder,
  ICompressSetDecoderProperties2,
  ICompressSetCoderMt
)
#endif
  CMyComPtr < ISequentialInStream > _inStream;

  DProps _props;

  UInt64 _processedIn;
  UInt64 _processedOut;
  UInt32 _inputSize;
  UInt32 _numThreads;

  HRESULT CodeSpec(ISequentialInStream *inStream, ISequentialOutStream *outStream, ICompressProgressInfo *progress);
  HRESULT SetOutStreamSizeResume(const UInt64 *outSize);

public:
  STDMETHOD (SetOutStreamSize)(const UInt64 *outSize);

#ifndef NO_READ_FROM_CODER
  UInt64 GetInputProcessedSize() const { return _processedIn; }
#endif
  HRESULT CodeResume(ISequentialOutStream *outStream, const UInt64 *outSize, ICompressProgressInfo *progress);

  CDecoder();
  virtual ~CDecoder();
};

}}
