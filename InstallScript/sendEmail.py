#!/usr/bin/python
    
from email.Message import Message
from email.MIMEAudio import MIMEAudio
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEImage import MIMEImage
from email.MIMEText import MIMEText
from email import Encoders
from config import Config
import os
import sys
import getopt
import mimetypes
import smtplib
import base64

class pythonEmail:
    """Usage: gmail.py -t recipients [-scfba] [--config]

    -t, --to=RECIPIENTS         if more than one recipients, seperate them by
                                a comma without space
    -s, --subject=SUBJECT       if it contains space, quote it
    -c, --cc=CC                 if more than one recipients, seperate them by 
                                a comma without space
    -f, --file=FILENAME         FILENAME will be treated as the main content
                                of the email 
    -a, --attachment=FILENAME   if more than one attachments, seperate them
                                by a comma without space
    -b, --body=STRING           STRING will be treated as the main content
                                if -f, --file is not give.
    --config                    modify the smtp server settings
    """

    def __init__(self):
        self.config_file = 'sendEmail.ini'
        self.settings = {
            'smtpServer':'smtp.gmail.com',
            'smtpPort':'587',
            'smtpTLS':'1',
            'smtpUsername':'bdna@bdnacn.com',
            'smtpPassword':'WW1SdVlVQXlNREk9Cg==\n',
            'sendFrom':'"GZ DP_UX_5.0 Sanity Check"<bdna@bdnacn.com>',
#            'sendTo':'"Jimmy Koo"<kukkiz@gmail.com>',
        }
        self.to = ""
        self.cc = ""
        self.subject = ""
        self.attachment = ""
        self.body = ""
        self.file = ""
        self.needConfirm = False

    def to(self, str):
        self.to = str

    def cc(self, str):
        self.cc = str

    def subject(self, str):
        self.subject = str

    def attachment(self, str):
        self.attachment = str

    def body(self, str):
        self.body = str

    def loadSettings(self):
        SMTPSettings = Config()
        SMTPSettings.file = self.config_file
        SMTPSettings.settings = self.settings
        SMTPSettings.needConfirm = self.needConfirm
        SMTPSettings.Run()
        self.smtpServer = SMTPSettings.settings['smtpServer']
        self.smtpUsername = SMTPSettings.settings['smtpUsername']
        self.smtpPassword = SMTPSettings.settings['smtpPassword']
        self.sendFrom = SMTPSettings.settings['sendFrom']
        self.smtpTLS = SMTPSettings.settings['smtpTLS']
        self.smtpPort = SMTPSettings.settings['smtpPort']
#        self.to = SMTPSettings.settings['sendTo']
        
    def mail(self):
        self.loadSettings()

        if not self.to:
            self.usage (1, 'recipient not defined')
        if self.cc:
            self.recips = ','.join([self.to, self.cc])
        else:
            self.recips = self.to

        if os.path.isfile(self.file):
            self.body = open(self.file, 'r').read()
        else:
            if not self.body: self.usage(1, 'file "%s" not found' % self.file)


        msg = MIMEMultipart()
    
        msg['From'] = self.sendFrom
        msg['To'] = self.to
        msg['Cc'] = self.cc
        msg['Subject'] = self.subject
    
        msg.attach(MIMEText(self.body))
    
        if self.attachment:
            commaSpace = ','
            attachmentList = self.attachment.split(commaSpace)
            for filename in attachmentList:
                filebasename = os.path.basename(filename)
                if not os.path.isfile(filename):
                    self.usage (1, 'attachment: "%s" not found' %  filename)
                ctype, encoding = mimetypes.guess_type(filename)
                print 'attaching file: ', filename, '(', ctype, encoding, ')'
                if ctype is None or encoding is not None:
                    # No guess could be made, or the file is encoded(compressed), so
                    # use a generic bag-of-bits type.
                    ctype = 'application/octet-stream'
                maintype, subtype = ctype.split('/', 1)
                if maintype == 'text':
                    fp = open(filename)
                    # Note: we should handle calculating the charset
                    attach = MIMEText(fp.read(), _subtype=subtype)
                    fp.close()
                elif maintype == 'image':
                    fp = open(filename, 'rb')
                    attach = MIMEImage(fp.read(), _subtype=subtype)
                    fp.close()
                elif maintype == 'audio':
                    fp = open(filename, 'rb')
                    attach = MIMEAudio(fp.read(), _subtype=subtype)
                    fp.close()
                else:
                    fp = open(filename, 'rb')
                    attach = MIMEBase(maintype, subtype)
                    attach.set_payload(fp.read())
                    fp.close()
                    # Encode the payload using Base64
                    Encoders.encode_base64(attach)
                # Set the filename parameter
                attach.add_header('Content-Disposition', 'attachment', filename=filebasename)
                msg.attach(attach)


        # Now send the email
        mailServer = smtplib.SMTP(self.smtpServer, self.smtpPort)
        # mailServer.set_debuglevel(1)
        # mailServer.debuglevel=5
        mailServer.ehlo()
        if self.smtpUsername:
            mailServer.esmtp_features["auth"] = "LOGIN"
        if self.smtpTLS in ('1', 'TRUE', 'True', 'true'):
            mailServer.starttls()
            mailServer.ehlo()
        mailServer.login(self.smtpUsername, base64.decodestring(base64.decodestring(self.smtpPassword)))
        for recip in self.recips.split(','):
            print 'sending email to:', recip
            mailServer.sendmail(self.sendFrom, recip, msg.as_string())
        # Should be mailServer.quit(), but that crashes...
        mailServer.close()
    
    def usage(self, code, msg=''):
        print >> sys.stderr, self.__doc__
        if msg: print >> sys.stderr, 'ERROR: %s' % msg
        sys.exit(code)

if __name__ == '__main__':
    attachment, body, subject, cc, to = ["", "", "", "", ""]

    dbBackupNotice = pythonEmail()

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'hb:a:f:s:c:t:', ['help', 'attachment=', 'file=', 'subject=', 'cc=', 'to=', 'config'])
    except getopt.error, msg:
        dbBackupNotice.usage(1, msg)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            dbBackupNotice.usage(0)
        elif opt in ('-a', '--attachment'):
            dbBackupNotice.attachment = arg
        elif opt in ('-b', '--body'):
            dbBackupNotice.body = arg
        elif opt in ('-f', '--file'):
            dbBackupNotice.file = arg
        elif opt in ('-s', '--subject'):
            dbBackupNotice.subject = arg
        elif opt in ('-c', '--cc'):
            dbBackupNotice.cc = arg
        elif opt in ('-t', '--to'):
            dbBackupNotice.to = arg
        elif opt in ('--config'):
            dbBackupNotice.needConfirm = True

    dbBackupNotice.mail()

