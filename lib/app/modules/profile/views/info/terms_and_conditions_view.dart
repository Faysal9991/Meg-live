import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class TermsAndConditionsView extends GetView {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Terms & Conditions'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: AppCard(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Html(data: htmlData),
            ),
          ),
        ),
      ),
    );
  }
}

const htmlData = r"""
<div id="tandc_content">

  <strong>Terms &amp; Conditions</strong>

  <p>
    By downloading or using the Biho Live app, these Terms and Conditions
    automatically apply to you. You should therefore read them carefully
    before using the app.
  </p>

  <p>
    You are not allowed to copy or modify the app, any part of the app,
    or our trademarks in any way. You are not allowed to attempt to
    extract the source code of the app, translate the app into other
    languages, or create derivative versions without authorization.
  </p>

  <p>
    The app itself, including all trademarks, copyrights, database rights,
    and other intellectual property rights related to it, belongs to
    Biho Live or its respective licensors.
  </p>

  <p>
    Biho Live is committed to ensuring that the app is as useful,
    reliable, and efficient as possible.
  </p>

  <p>
    For that reason, we reserve the right to make changes to the app,
    add or remove features, or charge for certain services where applicable.
    We will make it clear when a feature or service requires payment.
  </p>

  <p>
    The Biho Live app may store and process personal data that you provide
    to us in order to provide and improve the Service.
  </p>

  <p>
    It is your responsibility to keep your device and access to the app
    secure. We recommend that you do not jailbreak or root your device.
  </p>

  <p>
    Jailbreaking or rooting may remove software restrictions imposed by
    the official operating system and could make your device vulnerable
    to malware, viruses, malicious programs, or other security risks.
    It may also cause Biho Live to stop working properly.
  </p>

  <div>
    <p>
      The app may use third-party services that have their own
      Terms and Conditions.
    </p>

    <p>
      Links to the Terms and Conditions of third-party service providers
      used by the app:
    </p>

    <ul>
      <li>
        <a
          href="https://policies.google.com/terms"
          target="_blank"
          rel="noopener noreferrer">
          Google Play Services
        </a>
      </li>

      <li>
        <a
          href="https://firebase.google.com/terms/analytics"
          target="_blank"
          rel="noopener noreferrer">
          Google Analytics for Firebase
        </a>
      </li>

      <li>
        <a
          href="https://firebase.google.com/terms/crashlytics"
          target="_blank"
          rel="noopener noreferrer">
          Firebase Crashlytics
        </a>
      </li>
    </ul>
  </div>

  <p><strong>Internet Connection</strong></p>

  <p>
    Certain functions of Biho Live require an active internet connection.
    The connection may be provided through Wi-Fi or your mobile network.
  </p>

  <p>
    Biho Live cannot be held responsible if some or all features of the app
    are unavailable because you do not have an internet connection,
    sufficient mobile data, or reliable network coverage.
  </p>

  <p>
    If you use the app outside an area with Wi-Fi, the terms and charges
    of your mobile network provider will apply.
  </p>

  <p>
    You may be charged by your mobile provider for mobile data,
    roaming, or other network-related charges while using the app.
    You are responsible for any such charges.
  </p>

  <p>
    If you are not the bill payer for the device on which you are
    using the app, we assume that you have obtained permission from
    the bill payer to use the app.
  </p>

  <p><strong>Device Responsibility</strong></p>

  <p>
    Biho Live cannot accept responsibility for problems caused by
    your device being unavailable, unsupported, damaged, out of battery,
    or unable to connect to the Service.
  </p>

  <p>
    You are responsible for ensuring that your device remains functional,
    secure, and compatible with the app.
  </p>

  <p><strong>Service Information</strong></p>

  <p>
    While we endeavor to keep the Service accurate and up to date,
    some information or functionality may depend on third-party services.
  </p>

  <p>
    Biho Live cannot guarantee that all third-party information,
    services, or content will always be available, complete, accurate,
    or error-free.
  </p>

  <p>
    To the extent permitted by applicable law, Biho Live shall not be
    responsible for losses resulting from your reliance on third-party
    information or services available through the app.
  </p>

  <p><strong>App Updates</strong></p>

  <p>
    We may update Biho Live from time to time to improve performance,
    security, compatibility, features, and user experience.
  </p>

  <p>
    The requirements for Android or any other platforms that we may
    support in the future can change over time.
  </p>

  <p>
    You may need to install updates in order to continue using some
    or all features of the Service.
  </p>

  <p>
    We do not guarantee that Biho Live will always support every
    operating system version or device.
  </p>

  <p><strong>Termination</strong></p>

  <p>
    We may suspend or stop providing all or part of the Service where
    reasonably necessary, including for security, legal, maintenance,
    policy, or operational reasons.
  </p>

  <p>
    Upon termination of your right to use the Service:
  </p>

  <ul>
    <li>
      The rights and licenses granted to you under these Terms will end.
    </li>
    <li>
      You must stop using the app where required.
    </li>
    <li>
      You may need to remove the app from your device.
    </li>
  </ul>

  <p><strong>User Conduct</strong></p>

  <p>
    You agree to use Biho Live responsibly and in accordance with
    applicable laws and these Terms and Conditions.
  </p>

  <p>
    You must not use the Service to distribute illegal, abusive,
    harmful, fraudulent, threatening, or otherwise prohibited content.
  </p>

  <p>
    You must not attempt to interfere with the Service, gain unauthorized
    access to another user's account, misuse another person's identity,
    or use the Service for unlawful activities.
  </p>

  <p><strong>Account Security</strong></p>

  <p>
    You are responsible for maintaining the confidentiality and security
    of your account credentials and for activities carried out through
    your account.
  </p>

  <p>
    If you believe that your account has been accessed without
    authorization, you should contact us as soon as possible.
  </p>

  <p><strong>Virtual Items and Features</strong></p>

  <p>
    Biho Live may provide virtual items, gifts, coins, diamonds,
    subscriptions, VIP features, or other digital features.
  </p>

  <p>
    These virtual items are intended for use only within the Service
    and do not represent legal currency, stored monetary value,
    or ownership of physical property unless explicitly stated otherwise.
  </p>

  <p>
    Availability, pricing, usage rules, and eligibility for virtual
    features may change from time to time in accordance with applicable
    platform policies and laws.
  </p>

  <p><strong>Changes to These Terms and Conditions</strong></p>

  <p>
    We may update our Terms and Conditions from time to time.
    Therefore, you are advised to review this page periodically
    for any changes.
  </p>

  <p>
    We will notify users of changes by posting the updated
    Terms and Conditions on this page.
  </p>

  <p>
    These Terms and Conditions are effective as of 2026-09-16.
  </p>

  <p><strong>Contact Us</strong></p>

  <p>
    If you have any questions or suggestions about our Terms and Conditions,
    do not hesitate to contact us at
    <a href="mailto:biholive88@gmail.com">biholive88@gmail.com</a>.
  </p>

</div>
""";