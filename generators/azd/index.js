"use strict";
import Generator from "yeoman-generator";
import chalk from "chalk";
import us from "underscore.string";
import pkg from '../../package.json' with { type: "json" };

export default class extends Generator {
  constructor(args, opts) {
    super(args, opts);

    this.props = {
      generatorVersion: pkg.version,
    };
  }

  async prompting() {
    const currentDir = this.destinationPath().split("/").pop();
    const prompts = [
      {
        type: "string",
        name: "targetLocation",
        message: "Where do you want to generate the AZD files?",
        default: "./",
      },
      {
        type: "string",
        name: "solutionName",
        nessage: "Short solution name",
        default: us.titleize(us.humanize(currentDir)),
      },
      {
        type: "string",
        name: "solutionSlug",
        nessage: "Solution slug (lowercase, no spaces, dashes)",
        default: (answers) => us.slugify(answers.solutionName),
      },
      {
        type: "string",
        name: "creatorName",
        message: "What is the name of the solution creator?",
        default: await this.git.name(),
      },
      {
        type: "string",
        name: "creatorEmail",
        message: "What is the email of the solution creator?",
        default: await this.git.email(),
      },
      {
        type: "confirm",
        name: "withHooks",
        message: "Do you want to include AZD hooks?",
        default: true,
      },
      {
        type: "checkbox",
        name: "hooks",
        message: "Which hooks do you want to include?",
        choices: [
          {
            name: 'preup',
            value: 'preup',
          },
          {
            name: 'prerestore',
            value: 'prerestore',
          },
          {
            name: 'prepackage',
            value: 'prepackage',
          },
          {
            name: 'preprovision',
            value: 'preprovision',
          },
          {
            name: 'predeploy',
            value: 'predeploy',
          },
          {
            name: 'predown',
            value: 'predown',
          },
          {
            name: 'postup',
            value: 'postup',
          },
          {
            name: 'postrestore',
            value: 'postrestore',
          },
          {
            name: 'postpackage',
            value: 'postpackage',
          },
          {
            name: 'postprovision',
            value: 'postprovision',
          },
          {
            name: 'postdeploy',
            value: 'postdeploy',
          },
          {
            name: 'postdown',
            value: 'postdown',
          },
        ],
        when: (answers) => answers.withHooks,
      },
      {
        type: "confirm",
        name: "hookLogging",
        message: "Do you want to include log statements in your hooks?",
        default: true,
        when: (answers) => answers.withHooks,
      },

    ];

    return this.prompt(prompts).then(answers => {
      this.props = { ...this.props, ...answers };
      this.props.authorContact = `${this.props.creatorName} <${this.props.creatorEmail}>`;
      this.destinationRoot(this.props.targetLocation);
    });
  }

  writing() {
    this.log(`🚀 Scaffolding AZD in '${this.props.targetLocation}'...`);

    this.fs.copyTpl(
      this.templatePath("azure.yaml"),
      this.destinationPath("azure.yaml"),
      this.props
    );

    this.fs.copyTpl(
      this.templatePath("infra"),
      this.destinationPath("infra"),
      this.props
    );

    if (this.props.withHooks) {
      this.props.hooks.forEach((hook) => {
        this.fs.copyTpl(
          this.templatePath(`hook.sh`),
          this.destinationPath(`infra/hooks/${hook}.sh`),
          { ...this.props, hook: hook }
        );
      });
    }

    return false;
  }

  end() {
    this.log(chalk.green(`🎉 'AZD has been successfully scaffolded in  '${this.props.targetLocation}'.`));
  }
}

