# frozen_string_literal: true

target :app do
  signature "sig"

  check "lib"

  library "json"
  library "fileutils"
  library "uri"
  library "open-uri"

  configure_code_diagnostics(Steep::Diagnostic::Ruby.lenient)
end
