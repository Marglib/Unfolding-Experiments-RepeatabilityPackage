import sys
import optparse
import os
import xml.etree.ElementTree as ET
import re
from xml.dom import minidom

def createPlaceDictionary(modelFile, unfoldedFile):
    placeDict = {}
    transDict = {}
    tree = ET.parse(modelFile)
    for child in tree.iter():
        if('place' in child.tag):
            placeDict[child.attrib['id']] = []
        if('transition' in child.tag):
            transDict[child.attrib['id']] = []
    
    tree = ET.parse(unfoldedFile)
    for child in tree.iter():
        if('place' in child.tag):
            for key in placeDict:
                if child.attrib['id'].replace('_','').replace('-','').startswith(key.replace('-','').replace('_','')):
                #if child.attrib['id'].replace('-','_').startswith(key.replace('-','_')):
                    placeDict[key].append(child.attrib['id'])
        if('transition' in child.tag):
            for key in transDict:
                if child.attrib['id'].replace('_','').replace('-','').startswith(key.replace('-','').replace('_','')):
                #if child.attrib['id'].replace('-','_').startswith(key.replace('-','_')):
                    transDict[key].append(child.attrib['id'])



    print(transDict)
    return placeDict, transDict
    
def addPlacesToIntegerSum(placeList, sumNode):
    for place in placeList:
        tokensCountNode = ET.SubElement(sumNode,"tokens-count")
        placeNode = ET.SubElement(tokensCountNode, "place")
        placeNode.text = place

def addTransitionsToDisjunction(transitionList, disjunctionNode):
    
    for transition in transitionList:
        isfireableNode = ET.SubElement(disjunctionNode,"is-fireable")
        transitionNode = ET.SubElement(isfireableNode, "transition")
        transitionNode.text = transition

def constructUnfoldedQuery(placeDict, transDict, options):
    tree = ET.parse(options.queryFile)
    for parent in tree.iter():
        toRemove = []
        toAdd = []
        for child in parent:
            if 'tokens-count' in child.tag:
                #remove this if we run into problems
                if not child[0].text in placeDict:
                    continue
                #We do this to maintain the order of elements
                if len(placeDict[child[0].text]) < 2:
                    toAdd.append(child)
                    toRemove.append(child)
                else :
                    sumNode = ET.Element("integer-sum")
                    addPlacesToIntegerSum(placeDict[child[0].text], sumNode)
                    toAdd.append(sumNode)
                    toRemove.append(child)
            elif 'is-fireable' in child.tag:
                #remove this if we run into problems
                if not child[0].text in transDict:
                    continue
                if len(transDict[child[0].text]) < 2:
                    toAdd.append(child)
                    toRemove.append(child)
                else:
                    disjunctionNode = ET.Element("disjunction")
                    addTransitionsToDisjunction(transDict[child[0].text], disjunctionNode)
                    toAdd.append(disjunctionNode)
                    toRemove.append(child)
                
        for child in toRemove:
            parent.remove(child)
        for child in toAdd:
            parent.append(child)

    ET.register_namespace('', "http://mcc.lip6.fr/")
    with open(options.outputFile, 'w') as f:
        tree.write(f, encoding='unicode')

def constructUnfoldedQueryForNetFile(options):
    with open(options.unfoldedFile) as f:
        content = f.readlines()
    content = [x.strip() for x in content] 
    content = [x for x in content if x.startswith(('tr', 'pl'))]
    
    tree = ET.parse(options.queryFile)
    for parent in tree.iter():
        replacement_map = {}
        #toAdd = []
        for i, child in enumerate(parent):
            if 'tokens-count' in child.tag:
                #remove this if we run into problems
                names = []
                #print(child[0].text)
                for line in content:
                    if line.startswith('pl ' + child[0].text +' '):
                        names = line.split(' ')
                        names = names[2:]
                        if child[0].text == 'P-masterList':
                            print(names)
                #print(names)
                #remove this if we run into problems
                if not names:
                    continue
                else:
                    tokensCountNode = ET.Element("tokens-count")
                    for place in names:
                        placeNode = ET.SubElement(tokensCountNode, "place")
                        placeNode.text = place
                    replacement_map[i] = child,tokensCountNode
            elif 'is-fireable' in child.tag:
                names = []
                for line in content:
                    if line.startswith('tr ' + child[0].text + ' '):
                        names = line.split(' ')
                        names = names[2:]
                #remove this if we run into problems
                if not names:
                    continue
                else:
                    isfireableNode = ET.Element("is-fireable")
                    for transition in names:
                        transitionNode = ET.SubElement(isfireableNode, "transition")
                        transitionNode.text = transition
                    replacement_map[i] = child,isfireableNode
                    
        for index, (el_to_remove, el_to_add) in replacement_map.items():
            parent.remove(el_to_remove)
            parent.insert(index, el_to_add)

    ET.register_namespace('', "http://mcc.lip6.fr/")
    with open(options.outputFile, 'w') as f:
        tree.write(f, encoding='unicode')    
    

def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option("-f","--coloredModel", type="string", dest="modelFile", default="")
    optParser.add_option("-u","--unfoldedModel", type="string", dest="unfoldedFile", default="")

    optParser.add_option("-q","--queryFile", type="string", dest="queryFile", default="")
    optParser.add_option("-o", "--outputQuery", type="string", dest="outputFile", default="")

    options, args = optParser.parse_args()
    return options


                  
# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options()
    #outputfile = options.outputfile
    """
    if options.inputfile == "":
        print("we require an input file")
        sys.exit()
    if options.outputfile == "":
        print("no output file found.")
        sys.exit()
    if not options.modelFile.endswith(".pnml"):
        print("Model file must be pnml file")
    if not options.queryFile.endswith(".xml"):
        print("Query file must be xml file")
    if not outputfile.endswith(".xml"):
        print("Output file must be xml file")
        sys.exit()
    """
    print(options.modelFile)
    print(options.queryFile)
    print("im am here: " + os.getcwd())
    if options.unfoldedFile.endswith('.pnml'):
        placeDict, transDict = createPlaceDictionary(options.modelFile, options.unfoldedFile)
        constructUnfoldedQuery(placeDict, transDict, options)
    elif options.unfoldedFile.endswith('.net'):
        constructUnfoldedQueryForNetFile(options)
    elif options.unfoldedFile.endswith('dict'):
        constructUnfoldedQueryForNetFile(options)
    #cleanFile(options.queryFile,outputfile)
    