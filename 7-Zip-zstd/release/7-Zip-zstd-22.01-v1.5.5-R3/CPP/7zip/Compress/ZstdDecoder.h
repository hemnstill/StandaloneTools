// (C) 2016 - 2018 Tino Reichardt

#define ZSTD_STATIC_LINKING_ONLY
#include "../../../C/Alloc.h"
#include "../../../C/zstd/zstd.h"
#include "../../../C/zstd/zstd_errors.h"

#include "../../Windows/System.h"
#include "../../Common/Common.h"
#include "../../Common/MyCom.h"
#include "../ICoder.h"
#include "../Common/StreamUtils.h"
#include "../Common/RegisterCodec.h"
#include "../Common/ProgressMt.h"

/**
 * possible return values @ 7zip:
 * S_OK / S_FALSE
 * E_NOTIMPL
 * E_NOINTERFACE
 * E_ABORT
 * E_FAIL
 * E_OUTOFMEMORY
 * E_INVALIDARG
 */

#define ZSTD_LEVEL_MIN      1
#define ZSTD_LEVEL_MAX     22
#define ZSTD_THREAD_MAX   256

namespace NCompress {
namespace NZSTD {

struct DProps
{
  DProps() { clear (); }
  void clear ()
  {
    memset(this, 0, sizeof (*this));
    _ver_major = ZSTD_VERSION_MAJOR;
    _ver_minor = ZSTD_VERSION_MINOR;
    _level = 3;
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

  ZSTD_DCtx* _ctx;
  void*  _srcBuf;
  void*  _dstBuf;
  size_t _srcBufSize;
  size_t _dstBufSize;

  UInt64 _processedIn;
  UInt64 _processedOut;

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
