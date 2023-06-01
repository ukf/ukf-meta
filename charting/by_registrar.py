#!/usr/bin/env python

'''
Analyse a SAML metadata file and build a histogram of entities binned against
their registrar.
'''

from xml.dom.minidom import parse
from urllib import urlopen
from datetime import date
import sys

REGISTRAR_NAME = {

	# eduGAIN participants
	"http://eduid.at":                  "AT",
	"http://federation.belnet.be/":     "BE",
	"http://cafe.rnp.br":               "BR",
	"http://www.canarie.ca":            "CA",
	"http://cofre.reuna.cl/":           "CL",
	"https://www.carsi.edu.cn":         "CN",
	"http://www.srce.hr":               "HR",
	"http://www.eduid.cz/":             "CZ",
	"https://www.wayf.dk":              "DK",
	"http://www.csc.fi/haka":           "FI",
	"https://federation.renater.fr/":   "FR",
	"https://www.aai.dfn.de":           "DE",
	"http://aai.grnet.gr/":             "GR",
	"http://eduid.hu":                  "HU",
	"http://www.heanet.ie":             "IE",
	"http://www.idem.garr.it/":         "IT",
	"http://laife.lanet.lv/":           "LV",
	"http://feide.no/":                 "NO",
	"http://aai.arnes.si":              "SI",
	"http://www.rediris.es/":           "ES",
	"http://www.swamid.se/":            "SE",
	"http://rr.aai.switch.ch/":         "CH",
	"http://www.surfconext.nl/":        "NL",
	"http://ukfederation.org.uk":       "UK",

	# Joining eduGAIN
	"http://aai.pionier.net.pl":        "PL",

	# not yet eduGAIN members
	"https://incommon.org":             "US",
}

def regAuth(uri):
	'''
	Returns a short registrar code, or the long authority URI if none is available.
	'''
	try:
		return REGISTRAR_NAME[uri]
	except KeyError:
		return uri

def display(infile, split):
	doc = parse(infile)

	# Pull out all of the RegistrationInfo elements, one per entity
	registrationInfos = doc.getElementsByTagNameNS("urn:oasis:names:tc:SAML:metadata:rpi",
		"RegistrationInfo")

	counts = dict();

	for info in registrationInfos:
		auth = regAuth(info.getAttribute("registrationAuthority"))
		try:
			counts[auth] += 1
		except KeyError:
			counts[auth] = 1

	counts = sorted(counts.items(), key=lambda item: item[1], reverse=True)

	first_counts = counts[0:split]
	rest_counts = counts[split:]
	for e in first_counts:
		print "%10s: %d" % (e[0], e[1])
	print "%10s: %d" % ("other", sum([e[1] for e in rest_counts]))

if len(sys.argv) == 2:
	display(sys.argv[1], 9)
else:
	cache_file = date.today().strftime("cache/%Y-%m.xml")
	print "Most recent monthly UK federation production aggregate (%s):" % (cache_file)
	display(cache_file, 9)

	print

	print "Current eduGAIN production aggregate:"
	display(urlopen("https://mds.edugain.org/edugain-v2.xml"), 9)
