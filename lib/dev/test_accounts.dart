// DEBUG-ONLY test data — fake domains/users. Never shipped (kDebugMode-guarded).

const List<String> kTestOtpauthUris = <String>[
  'otpauth://totp/Yashigani%3Aana%40agnosticsec.com?secret=APE2LJTLCSX45MKICXOPCRW26LFMTYDG&issuer=Yashigani&algorithm=SHA256&digits=8&period=30',
  'otpauth://totp/Yashigani%3Acondor%40agnosticsec.com?secret=V2JEIILVKAAT7BUZG66VUZPQNVYI4GDJ&issuer=Yashigani&algorithm=SHA512&digits=8&period=30',
  'otpauth://totp/Agnostic%20Compliance%20Suite%3Amax%40agnosticsec.com?secret=YHW5P2WDAKAYDPPGW3GB2I52TAFNTN4T&issuer=Agnostic%20Compliance%20Suite&algorithm=SHA256&digits=8&period=30',
  'otpauth://totp/GitHub%3Aoctocat%40github.test?secret=AVC4VB5QWF32WZ7YOQ7JMKEEZJEN6YLE&issuer=GitHub&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Slack%3Adev%40acme-team.test?secret=DJVVUDTVJHMWKLWXZALCOMPVYI&issuer=Slack&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Reddit%3Alurker%40reddit.test?secret=Y2BIQQKBP5IPFPT5&issuer=Reddit&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Twitter%3Ahandle%40x.test?secret=X6N4ZY5CCGHMZXWOYQBPEGUGVLHWADVZ&issuer=Twitter&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/AWS%3Aroot%40aws-acme.test?secret=G7CFXLRPODY3TVPDXIZ5HDJMXK72HW72&issuer=AWS&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Proton%3Auser%40proton.test?secret=JVEVKYN6OAASBCBEYK7OMOQ&issuer=Proton&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Okta%3Aadmin%40corp.test?secret=TCVDKACPX74R5D7K5RS6ZZGT7A2BEDUC&issuer=Okta&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Auth0%3Atenant%40auth0.test?secret=GSR7WWXC2RH5N3LDU5CAX5WP6ZAWIGRD&issuer=Auth0&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/ExampleBank%3Aclient%40bank.test?secret=2PHQZ4QMUOYKJUVZ34MP3N7HI7FCVFJN&issuer=ExampleBank&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/GovPortal%3Acitizen%40gov.test?secret=QBN2B4N7K4CNWK5SEWBSH6PR5OHJIJQP&issuer=GovPortal&algorithm=SHA1&digits=6&period=30',
];

const String kTestMigrationUri =
    'otpauth-migration://offline?data=CkYKFHHFdJ%2BY8ytZDa4ppbKoezFjFMu%2BEh1ZYXNoaWdhbmk6YW5hQGFnbm9zdGljc2VjLmNvbRoJWWFzaGlnYW5pIAIoAjACCkkKFG8qa/wvwMAyC%2BRqRN63PeZdn6ptEiBZYXNoaWdhbmk6Y29uZG9yQGFnbm9zdGljc2VjLmNvbRoJWWFzaGlnYW5pIAMoAjACCmYKFBrUneNOXBpcM1NMxD6Ru2cPN9zREi1BZ25vc3RpYyBDb21wbGlhbmNlIFN1aXRlOm1heEBhZ25vc3RpY3NlYy5jb20aGUFnbm9zdGljIENvbXBsaWFuY2UgU3VpdGUgAigCMAIKQAoU7wmyQfKkvqyfQ32UodzrMY0xU3sSGkdpdEh1YjpvY3RvY2F0QGdpdGh1Yi50ZXN0GgZHaXRIdWIgASgBMAIKOQoQbyE12dkqAGGHVLjqruaRpxIYU2xhY2s6ZGV2QGFjbWUtdGVhbS50ZXN0GgVTbGFjayABKAEwAgo1Cgo96IDRRUHPL5dnEhlSZWRkaXQ6bHVya2VyQHJlZGRpdC50ZXN0GgZSZWRkaXQgASgBMAI%3D';
