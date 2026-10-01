import { greet } from "./index";

describe("greet", () => {
  it("returns a greeting containing the name", () => {
    expect(greet("world")).toBe("hello from world");
  });
});
