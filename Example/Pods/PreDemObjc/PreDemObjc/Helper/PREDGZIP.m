//
//  PREDGZIP.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <zlib.h>

static const NSUInteger ChunkSize = 16384;

@implementation NSData (PREDGZIP)

- (NSData *)gzippedDataWithCompressionLevel:(float)level
{
    if ([self length])
    {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        stream.avail_in = (uint)[self length];
        stream.next_in = (Bytef *)[self bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
        if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK)
        {
            NSMutableData *data = [NSMutableData dataWithLength:ChunkSize];
            while (stream.avail_out == 0)
            {
                if (stream.total_out >= [data length])
                {
                    data.length += ChunkSize;
                }
                stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)([data length] - stream.total_out);
                deflate(&stream, Z_FINISH);
            }
            deflateEnd(&stream);
            data.length = stream.total_out;
            return data;
        }
    }
    return nil;
}

- (NSData *)gzippedData
{
    return [self gzippedDataWithCompressionLevel:-1.0f];
}

- (NSData *)gunzippedData
{
    if ([self length])
    {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uint)[self length];
        stream.next_in = (Bytef *)[self bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        NSMutableData *data = [NSMutableData dataWithLength:(NSUInteger)([self length] * 1.5)];
        if (inflateInit2(&stream, 47) == Z_OK)
        {
            int status = Z_OK;
            while (status == Z_OK)
            {
                if (stream.total_out >= [data length])
                {
                    data.length += [self length] / 2;
                }
                stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)([data length] - stream.total_out);
                status = inflate (&stream, Z_SYNC_FLUSH);
            }
            if (inflateEnd(&stream) == Z_OK)
            {
                if (status == Z_STREAM_END)
                {
                    data.length = stream.total_out;
                    return data;
                }
            }
        }
    }
    return nil;
}

@end
