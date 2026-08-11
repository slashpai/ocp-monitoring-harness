const Configuration = {
  extends: ['@commitlint/config-conventional'],
  ignores: [
    (msg) => /Signed-off-by: dependabot\[bot]/m.test(msg),
    (msg) => /Signed-off-by: github-actions\[bot]/m.test(msg),
  ],
};

export default Configuration;
