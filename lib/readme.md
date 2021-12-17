# a tiny active storage port.

right now it only supports direct uploads with the signed verification

# todo:

- upload the image with S3Upload service

```js
{
    "query": "\n  mutation CreateDirectUpload($filename: String!, $contentType: String!, $checksum: String!, $byteSize: Int!){\n    createDirectUpload( input: { \n      filename: $filename, \n      contentType: $contentType, \n      checksum: $checksum, \n      byteSize: $byteSize \n    }){\n      directUpload {\n        signedBlobId\n        url\n        headers\n        blobId\n        serviceUrl\n      }\n    }\n  }\n",
    "variables": {
        "checksum": "XDUKX6TAcpYh99GmzZ4Q9g==",
        "filename": "E3uoXmOXwAY1zvI.jpeg",
        "contentType": "image/jpeg",
        "byteSize": 39023
    }
}
```

- return format for graphql

```js

{
    "data": {
        "createDirectUpload": {
            "directUpload": {
                "signedBlobId": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcGtJIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0a32f6c7817adbe4d5836bf57cb3714d6017836d",
                "url": "https://hermessapp.s3.amazonaws.com/lkt6bw84pr3agu2s462ldpp5x1ao?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=0JTEFTEXHP4R8QCMC582%2F20211122%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211122T072249Z&X-Amz-Expires=300&X-Amz-SignedHeaders=content-length%3Bcontent-md5%3Bcontent-type%3Bhost&X-Amz-Signature=b6a75c3274a8342e7bda6ae713ff7a50a82eb35b8a8b2e08c0fe078abc932074",
                "headers": "{\"Content-Type\":\"image/jpeg\",\"Content-MD5\":\"XDUKX6TAcpYh99GmzZ4Q9g==\",\"Content-Disposition\":\"inline; filename=\\\"E3uoXmOXwAY1zvI.jpeg\\\"; filename*=UTF-8''E3uoXmOXwAY1zvI.jpeg\"}",
                "blobId": "2201",
                "serviceUrl": "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcGtJIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0a32f6c7817adbe4d5836bf57cb3714d6017836d/E3uoXmOXwAY1zvI.jpeg"
            }
        }
    }
}

```
