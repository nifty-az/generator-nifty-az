"use strict";
import Generator from "yeoman-generator";
import yosay from "yosay";
import chalk from "chalk";

export default class extends Generator {
  async prompting() {
    // Have Yeoman greet the user.
    this.log(
      yosay(`Welcome to the fine ${chalk.red("generator-aigbb")} generator!`)
    );

    const prompts = [
      {
        type: "confirm",
        name: "someAnswer",
        message: "Would you like to enable this option?",
        default: true
      }
    ];

    return this.prompt(prompts).then(props => {
      // To access props later use this.props.someAnswer;
      this.props = props;
    });
  }

  writing() {}

  install() {}
}
