// DEBUG-ONLY test data — fake domains/users. Never shipped (kDebugMode-guarded).

const List<String> kTestOtpauthUris = <String>[
  'otpauth://totp/Yashigani%3Aana%40agnosticsec.com?secret=HNOOECUZDBAULBVKOQGXH5VNVOMDB7OQ&issuer=Yashigani&algorithm=SHA256&digits=8&period=30',
  'otpauth://totp/Yashigani%3Acondor%40agnosticsec.com?secret=XJ33WT7VARD2TMEACJEXDX2LV2LRPP3H&issuer=Yashigani&algorithm=SHA512&digits=8&period=30',
  'otpauth://totp/Agnostic%20Compliance%20Suite%3Amax%40agnosticsec.com?secret=76IM5MROUWZ73NQCHUN76AJ7P3S4BWPV&issuer=Agnostic%20Compliance%20Suite&algorithm=SHA256&digits=8&period=30',
  'otpauth://totp/GitHub%3Aoctocat%40github.test?secret=KDUIXTRAFUXVFHA6SCFKFQJNK4SRWFRF&issuer=GitHub&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Slack%3Adev%40acme-team.test?secret=CUMAYCAOXWK3XQ6CVDTHSCMLKQ&issuer=Slack&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Reddit%3Alurker%40reddit.test?secret=MND7MXCY62UGSVJM&issuer=Reddit&algorithm=SHA1&digits=6&period=30',
  'otpauth://totp/Twitter%3Ahandle%40x.test?secret=GRMV2IHFN2LFGLENHYQD7A2NU2D5SQPS&issuer=Twitter&algorithm=SHA1&digits=8&period=30',
  'otpauth://totp/GitLab%3Amaintainer%40gitlab.test?secret=Y2UABHNZBGOM2PCXEKPFBCR5VSUXIIW5&issuer=GitLab&algorithm=SHA256&digits=6&period=30',
  'otpauth://totp/AWS%3Aroot%40aws-acme.test?secret=MGODK3Y65Q6X43BJ2SKWIMN36NSYVXXY&issuer=AWS&algorithm=SHA256&digits=6&period=30',
  'otpauth://totp/Proton%3Auser%40proton.test?secret=CBYWLIDY5FRXP5SJY5HM2HA&issuer=Proton&algorithm=SHA256&digits=6&period=30',
  'otpauth://totp/Okta%3Aadmin%40corp.test?secret=24YFFBZJVHOAPMVOUWVDCORXXDNDXUG3&issuer=Okta&algorithm=SHA256&digits=8&period=30',
  'otpauth://totp/Auth0%3Atenant%40auth0.test?secret=RSLYMI4XIFV25UFZFGVABW233BFARTLN&issuer=Auth0&algorithm=SHA256&digits=6&period=60',
  'otpauth://totp/ExampleBank%3Aclient%40bank.test?secret=RDFBSR2RHKT46CK7NNOHN2FVJYLKRCR3&issuer=ExampleBank&algorithm=SHA512&digits=8&period=30',
  'otpauth://totp/GovPortal%3Acitizen%40gov.test?secret=SDMWVIG2LRRMMICVXB77JA3MT6EKLOUS&issuer=GovPortal&algorithm=SHA512&digits=6&period=30',
];

const String kTestMigrationUri =
    'otpauth-migration://offline?data=CkYKFKonHetUDlqtAqAMzQDaTlZoPNiJEh1ZYXNoaWdhbmk6YW5hQGFnbm9zdGljc2VjLmNvbRoJWWFzaGlnYW5pIAIoAjACCkkKFOrzytNM26hkEIRxy7TiGSkdgR3FEiBZYXNoaWdhbmk6Y29uZG9yQGFnbm9zdGljc2VjLmNvbRoJWWFzaGlnYW5pIAMoAjACCmYKFAc44zFdP5G/%2BmhbIt11Q4aNpGftEi1BZ25vc3RpYyBDb21wbGlhbmNlIFN1aXRlOm1heEBhZ25vc3RpY3NlYy5jb20aGUFnbm9zdGljIENvbXBsaWFuY2UgU3VpdGUgAigCMAIKQAoUklMhhgU2eQ8a8Vn70SeKey73DHwSGkdpdEh1YjpvY3RvY2F0QGdpdGh1Yi50ZXN0GgZHaXRIdWIgASgBMAIKOQoQcIYOTjBtoabzZI0U//RwdxIYU2xhY2s6ZGV2QGFjbWUtdGVhbS50ZXN0GgVTbGFjayABKAEwAgo1CgofZPaWurnOHyLWEhlSZWRkaXQ6bHVya2VyQHJlZGRpdC50ZXN0GgZSZWRkaXQgASgBMAI%3D';
