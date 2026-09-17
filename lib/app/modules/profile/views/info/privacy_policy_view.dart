import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class PrivacyPolicyView extends GetView {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: const Text('Privacy Policy'),
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
<div id="privacy_content">

  <strong>Privacy Policy</strong>

  <p>
    Biho Live built the Biho Live app as a Free app.
    This SERVICE is provided by Biho Live at no cost and is intended
    for use as is.
  </p>

  <p>
    This page is used to inform visitors regarding our policies
    with the collection, use, and disclosure of Personal Information
    if anyone decides to use our Service.
  </p>

  <p>
    If you choose to use our Service, then you agree to the collection
    and use of information in relation to this policy.
    The Personal Information that we collect is used for providing
    and improving the Service.
    We will not use or share your information with anyone except
    as described in this Privacy Policy.
  </p>

  <p>
    The terms used in this Privacy Policy have the same meanings
    as in our Terms and Conditions, which are accessible through
    Biho Live unless otherwise defined in this Privacy Policy.
  </p>

  <p><strong>Information Collection and Use</strong></p>

  <p>
    For a better experience while using our Service, we may require
    you to provide us with certain personally identifiable information.
    Biho Live is a live streaming, broadcasting, social interaction,
    audio/video communication, and video conferencing application.
    The information that we request will be retained and used as
    described in this Privacy Policy.
  </p>

  <div>
    <p>
      The app may use third-party services that collect information
      used to identify you or help us operate and improve the Service.
    </p>

    <p>
      Links to the privacy policies of third-party service providers
      used by the app:
    </p>

    <ul>
      <li>
        <a
          href="https://www.google.com/policies/privacy/"
          target="_blank"
          rel="noopener noreferrer">
          Google Play Services
        </a>
      </li>

      <li>
        <a
          href="https://firebase.google.com/policies/analytics"
          target="_blank"
          rel="noopener noreferrer">
          Google Analytics for Firebase
        </a>
      </li>

      <li>
        <a
          href="https://firebase.google.com/support/privacy/"
          target="_blank"
          rel="noopener noreferrer">
          Firebase Crashlytics
        </a>
      </li>
    </ul>
  </div>

  <p><strong>Log Data</strong></p>

  <p>
    We want to inform you that whenever you use our Service,
    in the case of an error in the app, we may collect data and
    information through third-party products on your device,
    which is called Log Data.
  </p>

  <p>
    This Log Data may include information such as your device
    Internet Protocol ("IP") address, device name, operating system
    version, configuration of the app when utilizing our Service,
    the time and date of your use of the Service, and other statistics.
  </p>

  <p><strong>Cookies</strong></p>

  <p>
    Cookies are files with a small amount of data that are commonly
    used as anonymous unique identifiers. These are sent to your
    browser from the websites that you visit and are stored on
    your device's internal memory.
  </p>

  <p>
    This Service does not use these cookies explicitly.
    However, the app may use third-party code and libraries that
    use cookies or similar technologies to collect information
    and improve their services.
  </p>

  <p>
    You may have the option to accept or refuse these technologies
    depending on the third-party service or platform.
    If you refuse them, some portions of the Service may not function
    correctly.
  </p>

  <p><strong>Service Providers</strong></p>

  <p>
    We may employ third-party companies and individuals due to
    the following reasons:
  </p>

  <ul>
    <li>To facilitate our Service;</li>
    <li>To provide the Service on our behalf;</li>
    <li>To perform Service-related services;</li>
    <li>To assist us in analyzing how our Service is used.</li>
  </ul>

  <p>
    We want to inform users of this Service that these third parties
    may have access to Personal Information when required to perform
    tasks assigned to them on our behalf.
  </p>

  <p>
    However, they are obligated not to disclose or use the information
    for any other purpose except as required to provide their services.
  </p>

  <p><strong>Security</strong></p>

  <p>
    We value your trust in providing us with your Personal Information,
    therefore we strive to use commercially acceptable means of
    protecting it.
  </p>

  <p>
    However, no method of transmission over the internet or method
    of electronic storage is 100% secure and reliable, and we cannot
    guarantee its absolute security.
  </p>

  <p><strong>Links to Other Sites</strong></p>

  <p>
    This Service may contain links to other sites.
    If you click on a third-party link, you will be directed
    to that site.
  </p>

  <p>
    These external sites are not operated by us.
    Therefore, we strongly advise you to review the Privacy Policy
    of these websites.
  </p>

  <p>
    We have no control over and assume no responsibility for the
    content, privacy policies, or practices of any third-party
    sites or services.
  </p>

  <p><strong>Children's Privacy</strong></p>

  <div>
    <p>
      These Services are not intended for anyone under the age of 13.
      We do not knowingly collect personally identifiable information
      from children under 13 years of age.
    </p>

    <p>
      If we discover that a child under 13 has provided us with
      personal information, we will take reasonable steps to delete
      that information from our systems.
    </p>

    <p>
      If you are a parent or guardian and you are aware that your child
      has provided us with personal information, please contact us so
      that we can take the necessary actions.
    </p>
  </div>

  <p><strong>Changes to This Privacy Policy</strong></p>

  <p>
    We may update our Privacy Policy from time to time.
    Therefore, you are advised to review this page periodically
    for any changes.
  </p>

  <p>
    We will notify users of changes by posting the updated Privacy
    Policy on this page.
  </p>

  <p>
    This policy is effective as of 2026-09-16.
  </p>

  <p><strong>Contact Us</strong></p>

  <p>
    If you have any questions or suggestions about our Privacy Policy,
    do not hesitate to contact us at
    <a href="mailto:biholive88@gmail.com">biholive88@gmail.com</a>.
  </p>

</div>
""";