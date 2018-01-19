#!/usr/bin/env python
import os
import re
class Config:
    def __init__(self):
        tmpdir = os.getenv('tmp')
        if not tmpdir: tmpdir = '/tmp'
        self.needConfirm = False
        self.file = 'setting.conf'
        self.settings = {
            'savePath':'/home//',
            'tempPath': tmpdir,
        }

    def Load(self):
        if not os.path.isfile(self.file):
            #print 'file "%s" not found.' % self.file
            #print 'using default settings.'
            return False
        oFile = open(self.file)
        sContent = oFile.readlines()
        oFile.close
        for i in sContent:
            if not re.search(r'=', i):
                print 'no ='
                return False
            key, value = i.split(r'=')[:]
            self.settings[key.strip()]=value.strip()
        return True
        
    def Save(self):
        oFile = open(self.file, 'w+')
        sContent = ''
        for i in self.settings:
            key, value = i, self.settings[i]
            sContent += '%s = %s\n' % (key, value)
        oFile.write (sContent)
        oFile.close
        
    def Print(self):
        sContent = ''
        for i in self.settings:
            key, value = i, self.settings[i]
            sContent += '%s = %s\n' % (key, value)
        print sContent
        
    def Edit(self):
        for i in self.settings:
            key, value = i, self.settings[i]
            nv = raw_input('Set %s [%s]:' % (key, value))
            if nv:
                self.settings[key] = nv
        return self.settings
        
    def Run(self):
        tmpSetting = ""
        self.Load()
        if self.needConfirm:
            tmpSetting = self.Edit()
        if tmpSetting:
            self.Save()
