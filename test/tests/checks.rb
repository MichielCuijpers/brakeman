require_relative '../test'

class ChecksTests < Minitest::Test
  def setup_tracker options = {}
    options[:app_path] = "/tmp/NOT_REAL"
    options = Brakeman.set_options(options)
    app_tree = Brakeman::AppTree.from_options(options)
    @tracker = Brakeman::Tracker.new(app_tree, nil, options)
  end

  def test_default_checks
    t = setup_tracker

    all_checks = Brakeman::Checks.checks.length
    optional_checks = Brakeman::Checks.optional_checks.length
    default_checks = Brakeman::Checks.checks_to_run(t).length

    assert_operator all_checks, :>, default_checks
    assert_operator all_checks, :>, optional_checks
    assert_equal all_checks, default_checks + optional_checks
  end

  def test_run_all_checks
    t = setup_tracker run_all_checks: true

    assert_equal Brakeman::Checks.checks.length, Brakeman::Checks.checks_to_run(t).length
  end

  def test_run_single_check
    t = setup_tracker run_checks: ["CheckCrossSiteScripting"]

    assert_equal [Brakeman::CheckCrossSiteScripting], Brakeman::Checks.checks_to_run(t)
  end

  def test_enable_single_optional_check
    t = setup_tracker enable_checks: ["CheckSymbolDoS"]

    assert_includes Brakeman::Checks.checks_to_run(t), Brakeman::CheckSymbolDoS

    expected = Brakeman::Checks.checks.length - Brakeman::Checks.optional_checks.length + 1

    assert_equal expected, Brakeman::Checks.checks_to_run(t).length
  end

  def test_enable_optional_checks
    t = setup_tracker enable_checks: ["CheckSymbolDoS", "CheckUnscopedFind"]

    assert_includes Brakeman::Checks.checks_to_run(t), Brakeman::CheckSymbolDoS
    assert_includes Brakeman::Checks.checks_to_run(t), Brakeman::CheckUnscopedFind

    expected = Brakeman::Checks.checks.length - Brakeman::Checks.optional_checks.length + 2

    assert_equal expected, Brakeman::Checks.checks_to_run(t).length
  end
end
