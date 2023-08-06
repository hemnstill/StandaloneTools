// (C) 2016 Tino Reichardt

#define LZ5_STATIC_LINKING_ONLY
#include "../../../C/Alloc.h"
#include "../../../C/Threads.h"
#include "../../../C/lz5/lz5.h"
#include "../../../C/zstdmt/lz5-mt.h"

#include "../../Windows/System.h"
#include "../../Common/Common.h"
#include "../../Common/MyCom.h"
#include "../ICoder.h"
#include "../Common/StreamUtils.h"
#include "../Common/RegisterCodec.h"
#include "../Common/ProgressMt.h"

struct Lz5Stream {
  ISequentialInStream *inStream;
  ISequentialOutStream *outStream;
  ICompressProgressInfo *progress;
  UInt64 *processedIn;
  UInt64 *processedOut;
};

extern int Lz5Read(void *Stream, LZ5MT_Buffer * in);
extern int Lz5Write(void *Stream, LZ5MT_Buffer * in);

namespace NCompress {
namespace NLZ5 {

struct DProps
{
  DProps() { clear (); }
  void clear ()
  {
    memset(this, 0, sizeof (*this));
    _ver_major = LZ5_VERSION_MAJOR;
    _ver_minor = LZ5_VERSION_MINOR;
    _level = 1;
  }

  Byte _ver_major;
  Byte _ver_minor;
  Byte _level;
  Byte _reserved[2];
};

class CDecoder:public ICompressCoder,
  public ICompressSetDecoderProperties2,
#ifndef NO_READ_FROM_CODER
  public ICompressSetInStream,
#endif
  public ICompressSetCoderMt,
  public CMyUnknownImp
{
  CMyComPtr < ISequentialInStream > _inStream;

  DProps _props;

  UInt64 _processedIn;
  UInt64 _processedOut;
  UInt32 _inputSize;
  UInt32 _numThreads;

  HRESULT CodeSpec(ISequentialInStream *inStream, ISequentialOutStream *outStream, ICompressProgressInfo *progress);
  HRESULT SetOutStreamSizeResume(const UInt64 *outSize);

public:

  Z7_COM_QI_BEGIN2(ICompressCoder)
  Z7_COM_QI_ENTRY(ICompressSetDecoderProperties2)
#ifndef NO_READ_FROM_CODER
  Z7_COM_QI_ENTRY(ICompressSetInStream)
#endif
  Z7_COM_QI_ENTRY(ICompressSetCoderMt)
  Z7_COM_QI_END

  Z7_COM_ADDREF_RELEASE

public:
  Z7_IFACE_COM7_IMP(ICompressCoder)
  Z7_IFACE_COM7_IMP(ICompressSetDecoderProperties2)
#ifndef NO_READ_FROM_CODER
  Z7_IFACE_COM7_IMP(ICompressSetInStream)
#endif
  Z7_IFACE_COM7_IMP(ICompressSetCoderMt)
  STDMETHOD (SetOutStreamSize)(const UInt64 *outSize);

#ifndef NO_READ_FROM_CODER
  UInt64 GetInputProcessedSize() const { return _processedIn; }
#endif
  HRESULT CodeResume(ISequentialOutStream *outStream, const UInt64 *outSize, ICompressProgressInfo *progress);

  CDecoder();
  virtual ~CDecoder();
};

}}
