const Localize = require("@kamaal111/localize");
const en = require("../../Locales/en");

const DEFAULT_LOCALE = "en";

const locales = { en };

const keysFileTemplate = (input) => {
  return `//
//  Keys.swift
//
//
//  Created by Kamaal M Farah on 26/02/2023.
//

extension GALocales {
    public enum Keys: String {
${input}
    }
}
`;
};

const localizableFileTemplate = (input) => {
  return `/*
  Localizable.strings
  GALocales

  Created by Kamaal Farah on 26/02/2023.
  Copyright © 2023 Kamaal. All rights reserved.
*/

${input}
`;
};

const main = () => {
  const localize = new Localize(
    "Modules/GALocales/Sources/GALocales/Resources",
    "Modules/GALocales/Sources/GALocales/Keys.swift",
    locales,
    DEFAULT_LOCALE,
    2
  );
  localize.setKeysTemplate(keysFileTemplate);
  localize.setLocaleFileTemplate(localizableFileTemplate);
  localize.generateFiles().then(console.log("Done localizing"));
};

main();
