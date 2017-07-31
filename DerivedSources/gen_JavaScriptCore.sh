#!/bin/sh

LUT_LIST="\
    ArrayConstructor \
    ArrayIteratorPrototype \
    BooleanPrototype \
    DateConstructor \
    DatePrototype \
    ErrorPrototype \
    GeneratorPrototype \
    InspectorInstrumentationObject \
    IntlCollatorConstructor \
    IntlCollatorPrototype \
    IntlDateTimeFormatConstructor \
    IntlDateTimeFormatPrototype \
    IntlNumberFormatConstructor \
    IntlNumberFormatPrototype \
    JSDataViewPrototype \
    JSGlobalObject \
    JSInternalPromiseConstructor \
    JSONObject \
    JSPromisePrototype \
    JSPromiseConstructor \
    MapPrototype \
    ModuleLoaderPrototype \
    NumberConstructor \
    NumberPrototype \
    ObjectConstructor \
    ReflectObject \
    RegExpConstructor \
    SetPrototype \
    StringConstructor \
    StringIteratorPrototype \
    StringPrototype \
    SymbolConstructor \
    SymbolPrototype \
"

PYTHON=python
RUBY=ruby
PERL=perl
DELETE=rm

JAVASCRIPTCORE_DIR=../Source/JavaScriptCore
RUNTIME_DIR=${JAVASCRIPTCORE_DIR}/runtime

DERIVED_SOURCES_DIR="JavaScriptCore"

if ! [ -d "${DERIVED_SOURCES_DIR}" ]; then
	mkdir ${DERIVED_SOURCES_DIR}
fi

echo "Generating RegExpJitTables.h"
${PYTHON} ${JAVASCRIPTCORE_DIR}/create_regex_tables > ${DERIVED_SOURCES_DIR}/RegExpJitTables.h

for i in ${LUT_LIST}
do
	echo "Generating ${i}.lut.h"
	${PERL} ${JAVASCRIPTCORE_DIR}/create_hash_table ${RUNTIME_DIR}/${i}.cpp > ${DERIVED_SOURCES_DIR}/${i}.lut.h
done

echo "Generating Lexer.lut.h"
${PERL} ${JAVASCRIPTCORE_DIR}/create_hash_table ${JAVASCRIPTCORE_DIR}/parser/Keywords.table > ${DERIVED_SOURCES_DIR}/Lexer.lut.h

echo "Generating KeywordLookup.h"
${PYTHON} ${JAVASCRIPTCORE_DIR}/KeywordLookupGenerator.py ${JAVASCRIPTCORE_DIR}/parser/Keywords.table > ${DERIVED_SOURCES_DIR}/KeywordLookup.h

echo "Generating InitBytecodes.asm and Bytecodes.h"
${PYTHON} ${JAVASCRIPTCORE_DIR}/generate-bytecode-files --bytecodes_h ${DERIVED_SOURCES_DIR}/Bytecodes.h --init_bytecodes_asm ${DERIVED_SOURCES_DIR}/InitBytecodes.asm ${JAVASCRIPTCORE_DIR}/bytecode/BytecodeList.json

echo "Generating LLIntAssembly_cloop.h"
${RUBY} ${JAVASCRIPTCORE_DIR}/offlineasm_cloop/asm.rb -I${DERIVED_SOURCES_DIR} ${JAVASCRIPTCORE_DIR}/llint/LowLevelInterpreter.asm ${DERIVED_SOURCES_DIR}/LLIntAssembly_cloop.h


#echo "Generating JSCBuiltins.h"
JavaScriptCore_BUILTINS_SOURCES="\
    ${JAVASCRIPTCORE_DIR}/builtins/ArrayConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/ArrayIteratorPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/ArrayPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/AsyncFunctionPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/DatePrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/FunctionPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/GeneratorPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/GlobalObject.js \
    ${JAVASCRIPTCORE_DIR}/builtins/GlobalOperations.js \
    ${JAVASCRIPTCORE_DIR}/builtins/InspectorInstrumentationObject.js \
    ${JAVASCRIPTCORE_DIR}/builtins/InternalPromiseConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/IteratorHelpers.js \
    ${JAVASCRIPTCORE_DIR}/builtins/IteratorPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/MapPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/ModuleLoaderPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/NumberConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/NumberPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/ObjectConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/PromiseConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/PromiseOperations.js \
    ${JAVASCRIPTCORE_DIR}/builtins/PromisePrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/ReflectObject.js \
    ${JAVASCRIPTCORE_DIR}/builtins/RegExpPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/SetPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/StringConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/StringIteratorPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/StringPrototype.js \
    ${JAVASCRIPTCORE_DIR}/builtins/TypedArrayConstructor.js \
    ${JAVASCRIPTCORE_DIR}/builtins/TypedArrayPrototype.js \
"
echo "Generating js builtins"
${PYTHON} ${JAVASCRIPTCORE_DIR}/Scripts/generate-js-builtins.py --combined --output-directory ${DERIVED_SOURCES_DIR} --framework JavaScriptCore ${JavaScriptCore_BUILTINS_SOURCES}

echo "Generating YarrCanonicalizeUnicode.cpp"
${PYTHON} ${JAVASCRIPTCORE_DIR}/generateYarrCanonicalizeUnicode ${JAVASCRIPTCORE_DIR}/ucd/CaseFolding.txt ${DERIVED_SOURCES_DIR}/YarrCanonicalizeUnicode.cpp

# inspector
INSPECTOR_DOMAINS="\
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/ApplicationCache.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/CSS.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Console.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/DOM.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/DOMDebugger.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/DOMStorage.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Database.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Debugger.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/GenericTypes.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Heap.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Inspector.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/LayerTree.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Network.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/OverlayTypes.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Page.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Runtime.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/ScriptProfiler.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Timeline.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Worker.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/IndexedDB.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Memory.json \
    ${JAVASCRIPTCORE_DIR}/inspector/protocol/Replay.json \
"

${PYTHON} ${JAVASCRIPTCORE_DIR}/Scripts/generate-combined-inspector-json.py ${INSPECTOR_DOMAINS} > ${DERIVED_SOURCES_DIR}/CombinedDomains.json
${PYTHON} ${JAVASCRIPTCORE_DIR}/inspector/scripts/generate-inspector-protocol-bindings.py --framework JavaScriptCore --outputDir ${DERIVED_SOURCES_DIR} ${DERIVED_SOURCES_DIR}/CombinedDomains.json

echo "//# sourceURL=__InjectedScript_InjectedScriptSource.js" > ${DERIVED_SOURCES_DIR}/InjectedScriptSource.min.js
${PYTHON} ${JAVASCRIPTCORE_DIR}/Scripts/jsmin.py < ${JAVASCRIPTCORE_DIR}/inspector/InjectedScriptSource.js >> ${DERIVED_SOURCES_DIR}/InjectedScriptSource.min.js
${PERL} ${JAVASCRIPTCORE_DIR}/Scripts/xxd.pl InjectedScriptSource_js ${DERIVED_SOURCES_DIR}/InjectedScriptSource.min.js ${DERIVED_SOURCES_DIR}/InjectedScriptSource.h
${DELETE} ${DERIVED_SOURCES_DIR}/InjectedScriptSource.min.js
