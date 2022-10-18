# RabbitMQ Trust Store 

## Acknowlegement 

A special thank to [Luke Bakken](https://github.com/lukebakken) for opening up the original repository, and his continued guidance support through the discussion [here](https://groups.google.com/g/rabbitmq-users/c/sLXfiBGaKfQ)

## About this project 
I am trying to implement a Certificate Revocation List (CRL) -like feature in RabbitMQ broker via the white-listing mechanism offered by the Trust Store plugin. By activating and configuring the Trust Store plugin, only clients with their certificate stored inside the truststore can connect to the broker. 

However, as I investgated further, it seems that the Trust Store plugin will automatically add the CA of the broker's certificates to the trust store, and as a result, any client certificates signed by the same CA as per the broker will be able to bypass the trust store and connect to the broker, regardless on wether they are whitelisted or not. 

Hence, a key issue I wish to address is if I can use the Trust Store plugin to prevent the connection from clients that have cert that is signed by the same Root CA as per the broker. 

## Approach 
As I was going through the Trust Store Source Code, I found the schema for the Trust Store Plugin: 

[rabbitmq-server/deps/rabbitmq_trust_store/priv/schema/rabbitmq_trust_store.schema](https://github.com/rabbitmq/rabbitmq-server/blob/master/deps/rabbitmq_trust_store/priv/schema/rabbitmq_trust_store.schema)

In line 86 - 87, there is an option for the ssl_options.depth: 
```
{mapping, "trust_store.ssl_options.depth", "rabbitmq_trust_store.ssl_options.depth",
    [{datatype, integer}, {validators, ["byte"]}]}.
```

I also came across the following part in the RabbitMQ Documentations that talks about the depth: 
[Certificate Chains and Verification Depth](https://www.rabbitmq.com/ssl.html#peer-verification-depth) 

### Hypothesis 1

If the server certificate and client certificates are not signed by the same, immediate CA, the trust store is able to block the client from connecting to the broker. 

Certificate Structure: 

- **ROOT CA**
    - IntermediateClient CA
      - IssuingClient CA
        - rmq-1 (**client certificate**)
    - Intermediate Server CA 
      - IssuingServer CA 
        - rmq-0 (**server certificate**) 


### Hypothesis 2

If I limit the `trust_store.ssl_options.depth` to 1, while increases the depth of the certificate to 3, the trust store is able to block the client from connecting to the broker.  

Thus, I have added this line to the `rabbitmq.conf` file: 
```
trust_store.ssl_options.depth = 1
```
while using the same certificate generated as per above. 

## Getting Started
1. run the init.sh 
```
sh init.sh 
```
2. run command: 
```
docker-compose up
```

## Outcome and Conclusion
The client will still be able to pass through the trust store and connect to the broker as ultimately, the root CA cert needs to be examined to verify the validity of the intermediate CAs to form a complete chain of trust. 

The following line seems to have no effect on the behavior of of the broker. 
```
trust_store.ssl_options.depth = 1
```

Both Hypothesis 1 and Hypothesis 2 seemed to be false. 

## Other issues faced
1. If only partial CA-chain is provided (eg, omit the Root CA certificate) will cause SSL verification Failure. 
2. "Self-signed certificate present in the trust chain" do appears if the rabbitMQ is not configured correctly. 
3. I have attemptted to use the [tls-gen (Sepeate Certificate Chains)](https://github.com/rabbitmq/tls-gen) to generate server and client certificates with seperate intermediate CAs, the test result is eactly the same, can still connect with an empty Trust Store.  
